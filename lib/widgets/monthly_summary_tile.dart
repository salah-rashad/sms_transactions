import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'currency_text.dart';

class MonthlySummaryTile extends StatelessWidget {
  final String monthLabel;
  final double income;
  final double expense;
  final double savings;
  final VoidCallback? onTap;

  const MonthlySummaryTile({
    super.key,
    required this.monthLabel,
    required this.income,
    required this.expense,
    required this.savings,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(monthLabel).semiBold.large),
                  if (onTap != null)
                    Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.mutedForeground),
                ],
              ),
              const Divider(),
              if (savings > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CurrencyText(
                    amount: savings,
                    color: Colors.teal,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    prefix: 'Savings: ',
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildColumn('Income', income, Colors.green),
                  _buildColumn('Expense', expense, Colors.red),
                  _buildColumn('Net', income - expense,
                      income - expense >= 0 ? Colors.green : Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    ).withPadding(horizontal: 12, vertical: 4);
  }

  Widget _buildColumn(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label).muted.xSmall,
        const Gap(4),
        CurrencyText(
          amount: value,
          color: color,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color),
          includeCurrency: false,
        ),
      ],
    );
  }
}
