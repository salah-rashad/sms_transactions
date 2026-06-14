import 'package:flutter/material.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/domain/models/transaction.dart';
import 'package:sms_transactions/shared/widgets/currency_text.dart';

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
    final colors = context.appColors;
    final scheme = context.colorScheme;

    Color iconColor;
    IconData iconData;
    if (isIncome) {
      iconColor = transaction.isMarkedAsSalary ? scheme.primary : colors.income;
      iconData = Icons.arrow_downward;
    } else if (isBalanceCheck) {
      iconColor = colors.balance;
      iconData = Icons.info_outline;
    } else {
      iconColor = colors.expense;
      iconData = Icons.arrow_upward;
    }

    return Card(
      color: transaction.isMarkedAsSalary
          ? scheme.primary.withValues(alpha: 0.08)
          : null,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.work_outline, size: 12, color: scheme.primary),
                      const SizedBox(width: 3),
                      Text(
                        'Salary',
                        style: TextStyle(
                          fontSize: 10,
                          color: scheme.primary,
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
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CurrencyText(
                amount: transaction.amount,
                color: iconColor,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                prefix: isIncome ? '+' : '-',
                decimals: 2,
                includeCurrency: false,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction.source.displayName,
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
