import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      monthLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
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
    );
  }

  Widget _buildColumn(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        CurrencyText(
          amount: value,
          color: color,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          includeCurrency: false,
        ),
      ],
    );
  }
}
