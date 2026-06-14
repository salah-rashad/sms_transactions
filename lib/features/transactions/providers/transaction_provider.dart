import 'package:flutter/material.dart';
import 'package:sms_transactions/data/repositories/salary_repository.dart';
import 'package:sms_transactions/data/services/sms_parser.dart';
import 'package:sms_transactions/data/services/sms_service.dart';
import 'package:sms_transactions/domain/analytics/account_calculator.dart';
import 'package:sms_transactions/domain/models/account.dart';
import 'package:sms_transactions/domain/models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final SmsService _smsService = SmsService();
  final SalaryRepository _salaryRepo;

  TransactionProvider(this._salaryRepo);

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  final Set<String> _salaryMarkedIds = {};

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get rawExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get currentBalance => totalIncome - rawExpense;

  List<Account> get accounts => AccountCalculator.compute(_transactions);

  void toggleSalaryMark(String transactionId) {
    final t = _transactions.where((t) => t.id == transactionId).firstOrNull;
    if (t == null || t.type != TransactionType.income) return;
    t.isMarkedAsSalary = !t.isMarkedAsSalary;
    if (t.isMarkedAsSalary) {
      _salaryMarkedIds.add(transactionId);
      _salaryRepo.insertMark(transactionId);
    } else {
      _salaryMarkedIds.remove(transactionId);
      _salaryRepo.deleteMark(transactionId);
    }
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _salaryMarkedIds
        ..clear()
        ..addAll(await _salaryRepo.getMarks());

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

      for (final t in _transactions) {
        if (_salaryMarkedIds.contains(t.id)) {
          t.isMarkedAsSalary = true;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
