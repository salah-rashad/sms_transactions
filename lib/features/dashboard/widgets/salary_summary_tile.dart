import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/shared/widgets/currency_text.dart';

class SalarySummaryTile extends StatelessWidget {
  final double salary;
  final double otherIncome;
  final double expense;
  final double savings;
  final double remaining;
  final DateTime cycleStart;
  final DateTime? cycleEnd;
  final VoidCallback? onTap;

  const SalarySummaryTile({
    super.key,
    required this.salary,
    required this.otherIncome,
    required this.expense,
    required this.savings,
    required this.remaining,
    required this.cycleStart,
    this.cycleEnd,
    this.onTap,
  });

  String get _periodLabel {
    final fmt = DateFormat('d MMM yyyy');
    final start = fmt.format(cycleStart);
    final end = cycleEnd != null
        ? fmt.format(cycleEnd!.subtract(const Duration(days: 1)))
        : 'Present';
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = context.colorScheme;
    final spentPercent = salary > 0
        ? ((expense + savings) / salary).clamp(0.0, 1.0)
        : 0.0;
    final progressColor = spentPercent > 0.9
        ? colors.expense
        : spentPercent > 0.7
        ? colors.warning
        : colors.income;

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.yMMMM().format(cycleStart),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _periodLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.chevron_right, color: scheme.outlineVariant),
                ],
              ),
              const Divider(),
              CurrencyText(
                amount: salary,
                color: scheme.primary,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                prefix: 'Salary: ',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: spentPercent,
                        backgroundColor: colors.income.withValues(alpha: 0.15),
                        color: progressColor,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(spentPercent * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildColumn(context, 'Expense', expense, colors.expense),
                  if (savings > 0)
                    _buildColumn(context, 'Savings', savings, colors.savings),
                  _buildColumn(
                    context,
                    'Left',
                    remaining,
                    remaining >= 0 ? colors.income : colors.expense,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
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
