import 'transaction.dart';

class Account {
  final AccountSource source;
  final String displayName;
  final double currentBalance;
  final int transactionCount;
  final bool isEstimated;

  const Account({
    required this.source,
    required this.displayName,
    required this.currentBalance,
    required this.transactionCount,
    this.isEstimated = false,
  });
}
