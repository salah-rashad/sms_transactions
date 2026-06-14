import 'package:sms_transactions/domain/models/money_pool.dart';
import 'package:sms_transactions/domain/models/transaction.dart';

typedef MonthlyBreakdownEntry = ({
  double income,
  double expense,
  double savings,
});

class MonthlyBreakdown {
  MonthlyBreakdown._();

  static Map<String, MonthlyBreakdownEntry> compute(
    List<Transaction> transactions,
    List<PoolContribution> contributions,
  ) {
    final savingsMap = <String, double>{};
    for (final c in contributions) {
      final key = '${c.date.year}-${c.date.month.toString().padLeft(2, '0')}';
      savingsMap[key] = (savingsMap[key] ?? 0.0) + c.amount;
    }

    final map = <String, MonthlyBreakdownEntry>{};

    for (final t in transactions) {
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

  static List<({int year, int month})> activeMonths(
    List<Transaction> transactions,
  ) {
    final seen = <String>{};
    final months = <({int year, int month})>[];
    for (final t in transactions) {
      if (t.type == TransactionType.balanceCheck) continue;
      final key = '${t.date.year}-${t.date.month}';
      if (seen.add(key)) {
        months.add((year: t.date.year, month: t.date.month));
      }
    }
    months.sort((a, b) {
      final y = b.year.compareTo(a.year);
      return y != 0 ? y : b.month.compareTo(a.month);
    });
    return months;
  }
}
