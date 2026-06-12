import 'transaction.dart';

class Account {
  final AccountSource source;
  final String displayName;
  final double estimatedBalance;
  final double? announcedBalance;
  final int transactionCount;

  const Account({
    required this.source,
    required this.displayName,
    required this.estimatedBalance,
    this.announcedBalance,
    required this.transactionCount,
  });
}
