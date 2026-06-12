import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../services/sms_service.dart';
import '../services/sms_parser.dart';

class TransactionProvider extends ChangeNotifier {
  final SmsService _smsService = SmsService();

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get currentBalance => totalIncome - totalExpense;

  List<Account> get accounts {
    final bankTxns = _transactions
        .where((t) => t.source == AccountSource.bankAlAhly)
        .toList();
    final vfTxns = _transactions
        .where((t) => t.source == AccountSource.vfCash)
        .toList();

    final bankIncome = bankTxns
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final bankExpense = bankTxns
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    double? vfBalance;
    for (final t in vfTxns) {
      if (t.balance != null) {
        vfBalance ??= t.balance;
      }
    }

    return [
      Account(
        source: AccountSource.bankAlAhly,
        displayName: 'BanK-AlAhly',
        currentBalance: bankIncome - bankExpense,
        transactionCount: bankTxns.length,
        isEstimated: true,
      ),
      Account(
        source: AccountSource.vfCash,
        displayName: 'VF-Cash',
        currentBalance: vfBalance ?? 0.0,
        transactionCount: vfTxns.length,
      ),
    ];
  }

  bool _isSalary(Transaction t) {
    return t.type == TransactionType.income &&
        t.source == AccountSource.bankAlAhly &&
        t.amount >= 30000;
  }

  DateTime _effectiveMonthDate(Transaction t) {
    if (_isSalary(t) && t.date.day >= 24) {
      return DateTime(t.date.year, t.date.month + 1, 1);
    }
    return t.date;
  }

  Map<String, ({double income, double expense, double salary})> get monthlyBreakdown {
    final map = <String, ({double income, double expense, double salary})>{};

    for (final t in _transactions) {
      if (t.type == TransactionType.balanceCheck) continue;
      final effectiveDate = _effectiveMonthDate(t);
      final key =
          '${effectiveDate.year}-${effectiveDate.month.toString().padLeft(2, '0')}';
      final existing = map[key] ?? (income: 0.0, expense: 0.0, salary: 0.0);
      if (t.type == TransactionType.income) {
        map[key] = (
          income: existing.income + t.amount,
          expense: existing.expense,
          salary: existing.salary + (_isSalary(t) ? t.amount : 0.0),
        );
      } else {
        map[key] = (
          income: existing.income,
          expense: existing.expense + t.amount,
          salary: existing.salary,
        );
      }
    }

    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: map[k]!};
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final granted = await _smsService.requestPermission();
      if (!granted) {
        _error = 'SMS permission denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final messages = await _smsService.getFinancialSms();

      _transactions = messages
          .map((sms) => SmsParser.parse(sms))
          .whereType<Transaction>()
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
