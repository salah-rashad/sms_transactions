import 'package:shadcn_flutter/shadcn_flutter.dart';
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
      iconColor = transaction.isMarkedAsSalary ? Colors.indigo : Colors.green;
      iconData = Icons.arrow_downward;
    } else if (isBalanceCheck) {
      iconColor = Colors.blue;
      iconData = Icons.info_outline;
    } else {
      iconColor = Colors.red;
      iconData = Icons.arrow_upward;
    }

    return Card(
      padding: EdgeInsets.zero,
      borderColor: transaction.isMarkedAsSalary
          ? Colors.indigo.withValues(alpha: 0.3)
          : null,
      child: GestureDetector(
        onLongPress: isIncome ? onToggleSalary : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Basic(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            leadingAlignment: Alignment.center,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    transaction.counterparty ?? _typeLabel(transaction.type),
                  ).semiBold,
                ),
                if (transaction.isMarkedAsSalary)
                  SecondaryBadge(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.work_outline, size: 10, color: Colors.indigo),
                        const Gap(3),
                        const Text('Salary'),
                      ],
                    ),
                  ),
              ],
            ),
            subtitle: Text(_formatDate(transaction.date)).muted.xSmall,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CurrencyText(
                  amount: transaction.amount,
                  color: iconColor,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: iconColor,
                  ),
                  prefix: isIncome ? '+' : '-',
                  decimals: 2,
                  includeCurrency: false,
                ),
                const Gap(4),
                SecondaryBadge(
                  child: Text(
                    transaction.source == AccountSource.bankAlAhly
                        ? 'Bank-AlAhly'
                        : 'VF-Cash',
                  ),
                ),
              ],
            ),
            trailingAlignment: Alignment.center,
          ),
        ),
      ),
    ).withPadding(horizontal: 12, vertical: 3);
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
