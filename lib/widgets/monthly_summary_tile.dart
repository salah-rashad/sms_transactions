import 'package:flutter/material.dart';

class MonthlySummaryTile extends StatelessWidget {
  final String monthLabel;
  final double income;
  final double expense;
  final double salary;

  const MonthlySummaryTile({
    super.key,
    required this.monthLabel,
    required this.income,
    required this.expense,
    required this.salary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthLabel,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Divider(),
            if (salary > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildColumn('Salary', salary, Colors.indigo),
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
    );
  }

  Widget _buildColumn(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(2)} EGP',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
