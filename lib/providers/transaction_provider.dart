import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../models/account.dart';
import '../models/money_pool.dart';
import '../models/transaction.dart';
import '../services/sms_parser.dart';
import '../services/sms_service.dart';

class TransactionProvider extends ChangeNotifier {
  final SmsService _smsService = SmsService();
  final AppDatabase _db;

  TransactionProvider(this._db);

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  final MoneyPool _moneyPool = MoneyPool();
  final Set<String> _salaryMarkedIds = {};

  List<Transaction> get transactions => _transactions;

  bool get isLoading => _isLoading;

  String? get error => _error;

  MoneyPool get moneyPool => _moneyPool;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get rawExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalSavings => _moneyPool.totalContributed;

  double get totalExpense => rawExpense - totalSavings;

  double get currentBalance => totalIncome - rawExpense - totalSavings;

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

    Transaction? latestBankWithBalance;
    for (final t in bankTxns) {
      if (t.balance != null) {
        if (latestBankWithBalance == null || t.date.isAfter(latestBankWithBalance.date)) {
          latestBankWithBalance = t;
        }
      }
    }
    final bankAnnounced = latestBankWithBalance?.balance;

    Transaction? latestVfWithBalance;
    for (final t in vfTxns) {
      if (t.balance != null) {
        if (latestVfWithBalance == null || t.date.isAfter(latestVfWithBalance.date)) {
          latestVfWithBalance = t;
        }
      }
    }
    final vfAnnounced = latestVfWithBalance?.balance;

    return [
      Account(
        source: AccountSource.bankAlAhly,
        displayName: 'BanK-AlAhly',
        estimatedBalance: bankIncome - bankExpense,
        announcedBalance: bankAnnounced,
        transactionCount: bankTxns.length,
      ),
      Account(
        source: AccountSource.vfCash,
        displayName: 'VF-Cash',
        estimatedBalance: (vfAnnounced ?? 0.0),
        announcedBalance: vfAnnounced,
        transactionCount: vfTxns.length,
      ),
    ];
  }

  bool _isSalary(Transaction t) {
    return t.isMarkedAsSalary;

    // if (t.isMarkedAsSalary) return true;
    // return t.type == TransactionType.income &&
    //     t.source == AccountSource.bankAlAhly &&
    //     t.amount >= 30000;
  }

  void toggleSalaryMark(String transactionId) {
    final t = _transactions.where((t) => t.id == transactionId).firstOrNull;
    if (t == null || t.type != TransactionType.income) return;
    t.isMarkedAsSalary = !t.isMarkedAsSalary;
    if (t.isMarkedAsSalary) {
      _salaryMarkedIds.add(transactionId);
      _db.insertSalaryMark(transactionId);
    } else {
      _salaryMarkedIds.remove(transactionId);
      _db.deleteSalaryMark(transactionId);
    }
    notifyListeners();
  }

  Map<String, ({double income, double expense, double savings})>
  get monthlyBreakdown {
    final savingsMap = <String, double>{};
    for (final c in _moneyPool.contributions) {
      final key = '${c.date.year}-${c.date.month.toString().padLeft(2, '0')}';
      savingsMap[key] = (savingsMap[key] ?? 0.0) + c.amount;
    }

    final map = <String, ({double income, double expense, double savings})>{};

    for (final t in _transactions) {
      if (t.type == TransactionType.balanceCheck) continue;
      final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      final existing = map[key] ?? (income: 0.0, expense: 0.0, savings: 0.0);
      if (t.type == TransactionType.income) {
        map[key] = (
          income: existing.income + t.amount,
          expense: existing.expense,
          savings: existing.savings,
        );
      } else {
        map[key] = (
          income: existing.income,
          expense: existing.expense + t.amount,
          savings: existing.savings,
        );
      }
    }

    for (final entry in savingsMap.entries) {
      final existing =
          map[entry.key] ?? (income: 0.0, expense: 0.0, savings: 0.0);
      map[entry.key] = (
        income: existing.income,
        expense: existing.expense - entry.value,
        savings: existing.savings + entry.value,
      );
    }

    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: map[k]!};
  }

  Map<
    String,
    ({
      double salary,
      double otherIncome,
      double expense,
      double savings,
      double remaining,
      DateTime cycleStart,
      DateTime? cycleEnd,
    })
  >
  get salaryBasedBreakdown {
    final salaryTxns = _transactions.where((t) => _isSalary(t)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (salaryTxns.isEmpty) return {};

    final map =
        <
          String,
          ({
            double salary,
            double otherIncome,
            double expense,
            double savings,
            double remaining,
            DateTime cycleStart,
            DateTime? cycleEnd,
          })
        >{};

    for (int i = 0; i < salaryTxns.length; i++) {
      final salaryTxn = salaryTxns[i];
      final cycleStart = salaryTxn.date;
      final cycleEnd = i + 1 < salaryTxns.length
          ? salaryTxns[i + 1].date
          : null;

      final key =
          '${cycleStart.year}-${cycleStart.month.toString().padLeft(2, '0')}-${cycleStart.day.toString().padLeft(2, '0')}';

      double otherIncome = 0;
      double expense = 0;

      for (final t in _transactions) {
        if (t.type == TransactionType.balanceCheck) continue;
        if (t.date.isBefore(cycleStart)) continue;
        if (cycleEnd != null && !t.date.isBefore(cycleEnd)) continue;

        if (t.type == TransactionType.income && !_isSalary(t)) {
          otherIncome += t.amount;
        } else if (t.type == TransactionType.expense) {
          expense += t.amount;
        }
      }

      double savings = 0;
      for (final c in _moneyPool.contributions) {
        if (c.date.isBefore(cycleStart)) continue;
        if (cycleEnd != null && !c.date.isBefore(cycleEnd)) continue;
        savings += c.amount;
      }

      expense -= savings;

      map[key] = (
        salary: salaryTxn.amount,
        otherIncome: otherIncome,
        expense: expense,
        savings: savings,
        remaining: salaryTxn.amount + otherIncome - expense - savings,
        cycleStart: cycleStart,
        cycleEnd: cycleEnd,
      );
    }

    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: map[k]!};
  }

  void addPoolContribution(double amount, DateTime date) {
    final id = 'pool-${date.millisecondsSinceEpoch}';
    final contribution = PoolContribution(id: id, date: date, amount: amount);
    _moneyPool.contributions.add(contribution);
    _moneyPool.contributions.sort((a, b) => b.date.compareTo(a.date));
    _db.insertContribution(
      PoolContributionsCompanion.insert(
        id: id,
        date: date.millisecondsSinceEpoch,
        amount: amount,
      ),
    );
    notifyListeners();
  }

  void removePoolContribution(String id) {
    _moneyPool.contributions.removeWhere((c) => c.id == id);
    _db.deleteContribution(id);
    notifyListeners();
  }

  void togglePayoutReceived(int payoutIndex) {
    if (payoutIndex >= 0 && payoutIndex < _moneyPool.payouts.length) {
      _moneyPool.payouts[payoutIndex].isReceived =
          !_moneyPool.payouts[payoutIndex].isReceived;
      _db.setPayoutReceived(
        payoutIndex,
        _moneyPool.payouts[payoutIndex].isReceived,
      );
      notifyListeners();
    }
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load persisted data from DB
      final contributionRows = await _db.getAllContributions();
      _moneyPool.contributions
        ..clear()
        ..addAll(
          contributionRows.map(
            (row) => PoolContribution(
              id: row.id,
              date: DateTime.fromMillisecondsSinceEpoch(row.date),
              amount: row.amount,
            ),
          ),
        )
        ..sort((a, b) => b.date.compareTo(a.date));

      final payoutStateRows = await _db.getPayoutStates();
      for (final row in payoutStateRows) {
        if (row.payoutIndex >= 0 &&
            row.payoutIndex < _moneyPool.payouts.length) {
          _moneyPool.payouts[row.payoutIndex].isReceived = row.isReceived;
        }
      }

      final salaryMarkRows = await _db.getSalaryMarks();
      _salaryMarkedIds
        ..clear()
        ..addAll(salaryMarkRows.map((r) => r.transactionId));

      // Load SMS transactions
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

      // Re-apply persisted salary marks
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
