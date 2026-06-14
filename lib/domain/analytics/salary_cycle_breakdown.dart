import 'package:sms_transactions/domain/models/money_pool.dart';
import 'package:sms_transactions/domain/models/transaction.dart';

typedef SalaryCycleEntry = ({
  double salary,
  double otherIncome,
  double expense,
  double savings,
  double remaining,
  DateTime cycleStart,
  DateTime? cycleEnd,
});

class SalaryCycleBreakdown {
  SalaryCycleBreakdown._();

  static Map<String, SalaryCycleEntry> compute(
    List<Transaction> transactions,
    List<PoolContribution> contributions,
  ) {
    final salaryTxns = transactions.where((t) => t.isMarkedAsSalary).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (salaryTxns.isEmpty) return {};

    final map = <String, SalaryCycleEntry>{};

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

      for (final t in transactions) {
        if (t.type == TransactionType.balanceCheck) continue;
        if (t.date.isBefore(cycleStart)) continue;
        if (cycleEnd != null && !t.date.isBefore(cycleEnd)) continue;

        if (t.type == TransactionType.income && !t.isMarkedAsSalary) {
          otherIncome += t.amount;
        } else if (t.type == TransactionType.expense) {
          expense += t.amount;
        }
      }

      double savings = 0;
      for (final c in contributions) {
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

  static List<({DateTime start, DateTime? end})> cycleRanges(
    List<Transaction> transactions,
  ) {
    final salaryTxns = transactions.where((t) => t.isMarkedAsSalary).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return [
      for (int i = 0; i < salaryTxns.length; i++)
        (
          start: salaryTxns[i].date,
          end: i + 1 < salaryTxns.length ? salaryTxns[i + 1].date : null,
        ),
    ];
  }
}
