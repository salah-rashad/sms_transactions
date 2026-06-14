import 'package:sms_transactions/domain/models/account.dart';
import 'package:sms_transactions/domain/models/transaction.dart';

class AccountCalculator {
  AccountCalculator._();

  static List<Account> compute(List<Transaction> transactions) {
    final bankTxns = transactions
        .where((t) => t.source == AccountSource.bankAlAhly)
        .toList();
    final vfTxns = transactions
        .where((t) => t.source == AccountSource.vfCash)
        .toList();

    final bankIncome = bankTxns
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final bankExpense = bankTxns
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final vfIncome = vfTxns
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final vfExpense = vfTxns
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final bankAnnounced = _latestBalance(bankTxns);
    final vfAnnounced = _latestBalance(vfTxns);

    final bankEstimated = _estimateBalance(
      bankTxns,
      bankAnnounced,
      bankIncome,
      bankExpense,
    );
    final vfEstimated = _estimateBalance(
      vfTxns,
      vfAnnounced,
      vfIncome,
      vfExpense,
    );

    return [
      Account(
        source: AccountSource.bankAlAhly,
        displayName: AccountSource.bankAlAhly.displayName,
        estimatedBalance: bankEstimated,
        announcedBalance: bankAnnounced?.balance,
        transactionCount: bankTxns.length,
      ),
      Account(
        source: AccountSource.vfCash,
        displayName: AccountSource.vfCash.displayName,
        estimatedBalance: vfEstimated,
        announcedBalance: vfAnnounced?.balance,
        transactionCount: vfTxns.length,
      ),
    ];
  }

  static Transaction? _latestBalance(List<Transaction> txns) {
    Transaction? latest;
    for (final t in txns) {
      if (t.balance != null) {
        if (latest == null || t.date.isAfter(latest.date)) {
          latest = t;
        }
      }
    }
    return latest;
  }

  static double _estimateBalance(
    List<Transaction> txns,
    Transaction? latestWithBalance,
    double income,
    double expense,
  ) {
    if (latestWithBalance != null && latestWithBalance.balance != null) {
      double adjustment = 0;
      for (final t in txns) {
        if (t.type == TransactionType.balanceCheck) continue;
        if (!t.date.isAfter(latestWithBalance.date)) continue;
        if (t.type == TransactionType.income) {
          adjustment += t.amount;
        } else if (t.type == TransactionType.expense) {
          adjustment -= t.amount;
        }
      }
      return latestWithBalance.balance! + adjustment;
    }
    return income - expense;
  }
}
