import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final isBalanceCheck = transaction.type == TransactionType.balanceCheck;

    Color iconColor;
    IconData iconData;
    if (isIncome) {
      iconColor = Colors.green;
      iconData = Icons.arrow_downward;
    } else if (isBalanceCheck) {
      iconColor = Colors.blue;
      iconData = Icons.info_outline;
    } else {
      iconColor = Colors.red;
      iconData = Icons.arrow_upward;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.1),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(
          transaction.counterparty ?? _typeLabel(transaction.type),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          _formatDate(transaction.date),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} EGP',
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                transaction.source == AccountSource.bankAlAhly
                    ? 'BanK-AlAhly'
                    : 'VF-Cash',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.balanceCheck:
        return 'Balance Check';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
