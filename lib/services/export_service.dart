import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';

class ExportService {
  static Future<void> exportTransactions(List<Transaction> transactions) async {
    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];
    excel.delete('Sheet1');

    // Header row
    final headers = [
      'Date',
      'Time',
      'Type',
      'Account',
      'Amount (EGP)',
      'Balance (EGP)',
      'Counterparty',
      'Salary',
    ];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
    );

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Column widths
    sheet.setColumnWidth(0, 14); // Date
    sheet.setColumnWidth(1, 10); // Time
    sheet.setColumnWidth(2, 10); // Type
    sheet.setColumnWidth(3, 14); // Account
    sheet.setColumnWidth(4, 16); // Amount
    sheet.setColumnWidth(5, 16); // Balance
    sheet.setColumnWidth(6, 28); // Counterparty
    sheet.setColumnWidth(7, 8);  // Salary

    final dateFmt = DateFormat('dd/MM/yyyy');
    final timeFmt = DateFormat('HH:mm');

    final incomeStyle = CellStyle(fontColorHex: ExcelColor.fromHexString('#1D6B2E'));
    final expenseStyle = CellStyle(fontColorHex: ExcelColor.fromHexString('#C00000'));
    final balanceCheckStyle = CellStyle(fontColorHex: ExcelColor.fromHexString('#2F5496'));

    for (int i = 0; i < transactions.length; i++) {
      final t = transactions[i];
      final row = i + 1;

      CellStyle? amountStyle;
      String typeLabel;
      switch (t.type) {
        case TransactionType.income:
          typeLabel = 'Income';
          amountStyle = incomeStyle;
        case TransactionType.expense:
          typeLabel = 'Expense';
          amountStyle = expenseStyle;
        case TransactionType.balanceCheck:
          typeLabel = 'Balance';
          amountStyle = balanceCheckStyle;
      }

      final rowData = [
        dateFmt.format(t.date),
        timeFmt.format(t.date),
        typeLabel,
        t.source == AccountSource.bankAlAhly ? 'BanK-AlAhly' : 'VF-Cash',
        t.amount,
        t.balance ?? '',
        t.counterparty ?? '',
        t.isMarkedAsSalary ? 'Yes' : '',
      ];

      for (int j = 0; j < rowData.length; j++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row));
        final v = rowData[j];
        if (v is double) {
          cell.value = DoubleCellValue(v);
          cell.cellStyle = amountStyle;
        } else if (v is String) {
          cell.value = TextCellValue(v);
          if (j == 4 || j == 5) cell.cellStyle = amountStyle;
        }
      }
    }

    // Summary sheet
    final summary = excel['Summary'];
    _buildSummarySheet(summary, transactions);

    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');

    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final file = File('${dir.path}/transactions_$timestamp.xlsx');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
      subject: 'Transactions Export – $timestamp',
    );
  }

  static void _buildSummarySheet(Sheet sheet, List<Transaction> transactions) {
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    void writeHeader(int col, int row, String text) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      cell.value = TextCellValue(text);
      cell.cellStyle = headerStyle;
    }

    void writeValue(int col, int row, dynamic value) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      if (value is double) {
        cell.value = DoubleCellValue(value);
      } else {
        cell.value = TextCellValue(value.toString());
      }
    }

    final nonBalance = transactions.where((t) => t.type != TransactionType.balanceCheck).toList();
    final totalIncome = nonBalance
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final totalExpense = nonBalance
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);

    writeHeader(0, 0, 'Metric');
    writeHeader(1, 0, 'Amount (EGP)');
    sheet.setColumnWidth(0, 22);
    sheet.setColumnWidth(1, 18);

    final rows = [
      ['Total Income', totalIncome],
      ['Total Expense', totalExpense],
      ['Net', totalIncome - totalExpense],
      ['Total Transactions', nonBalance.length.toDouble()],
    ];

    for (int i = 0; i < rows.length; i++) {
      writeValue(0, i + 1, rows[i][0]);
      writeValue(1, i + 1, rows[i][1]);
    }

    // Monthly breakdown
    writeHeader(0, rows.length + 2, 'Month');
    writeHeader(1, rows.length + 2, 'Income');
    writeHeader(2, rows.length + 2, 'Expense');
    writeHeader(3, rows.length + 2, 'Net');
    sheet.setColumnWidth(2, 18);
    sheet.setColumnWidth(3, 18);

    final monthly = <String, ({double income, double expense})>{};
    for (final t in nonBalance) {
      final key = DateFormat('MMM yyyy').format(t.date);
      final existing = monthly[key] ?? (income: 0.0, expense: 0.0);
      monthly[key] = t.type == TransactionType.income
          ? (income: existing.income + t.amount, expense: existing.expense)
          : (income: existing.income, expense: existing.expense + t.amount);
    }

    // Sort newest first
    final sortedMonths = monthly.keys.toList()
      ..sort((a, b) {
        final da = DateFormat('MMM yyyy').parse(a);
        final db = DateFormat('MMM yyyy').parse(b);
        return db.compareTo(da);
      });

    int baseRow = rows.length + 3;
    for (final month in sortedMonths) {
      final v = monthly[month]!;
      writeValue(0, baseRow, month);
      writeValue(1, baseRow, v.income);
      writeValue(2, baseRow, v.expense);
      writeValue(3, baseRow, v.income - v.expense);
      baseRow++;
    }
  }
}
