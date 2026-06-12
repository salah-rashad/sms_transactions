enum TransactionType { income, expense, balanceCheck }

enum AccountSource { bankAlAhly, vfCash }

class Transaction {
  final String id;
  final AccountSource source;
  final TransactionType type;
  final double amount;
  final double? balance;
  final String? counterparty;
  final DateTime date;
  final String rawSms;

  const Transaction({
    required this.id,
    required this.source,
    required this.type,
    required this.amount,
    this.balance,
    this.counterparty,
    required this.date,
    required this.rawSms,
  });
}
