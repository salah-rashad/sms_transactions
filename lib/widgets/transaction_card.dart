import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../widgets/currency_text.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onToggleSalary;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onToggleSalary,
  });

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
      child: InkWell(
        onLongPress: isIncome ? onToggleSalary : null,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: iconColor.withValues(alpha: 0.1),
            child: Icon(iconData, color: iconColor),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  transaction.counterparty ?? _typeLabel(transaction.type),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              if (transaction.isMarkedAsSalary)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.work_outline, size: 12, color: Colors.indigo),
                      SizedBox(width: 3),
                      Text(
                        'Salary',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.indigo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          subtitle: Text(
            _formatDate(transaction.date),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CurrencyText(
                amount: transaction.amount,
                color: iconColor,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                prefix: isIncome ? '+' : '-',
                decimals: 2,
                includeCurrency: false,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
