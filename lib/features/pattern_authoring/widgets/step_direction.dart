import 'package:flutter/material.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/core/theme/app_colors.dart';
import 'package:sms_transactions/domain/models/sms_pattern.dart';

/// Step 3 (FR-011): classify the transaction direction as Income, Expense, or
/// Balance Check.
class StepDirection extends StatelessWidget {
  final SmsDirection? selected;
  final ValueChanged<SmsDirection> onSelect;

  const StepDirection({super.key, this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Transaction direction', style: context.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'How should this message be counted?',
          style: TextStyle(
            fontSize: 12,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        for (final option in SmsDirection.values)
          _DirectionTile(
            direction: option,
            selected: option == selected,
            onTap: () => onSelect(option),
          ),
      ],
    );
  }
}

class _DirectionTile extends StatelessWidget {
  final SmsDirection direction;
  final bool selected;
  final VoidCallback onTap;

  const _DirectionTile({
    required this.direction,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final colors = context.appColors;
    final (icon, label, subtitle, color) = _describe(direction, colors);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? color : scheme.outlineVariant,
          width: selected ? 1.6 : 1,
        ),
      ),
      color: selected ? color.withValues(alpha: 0.08) : scheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: color),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, String, String, Color) _describe(
    SmsDirection d,
    AppColors colors,
  ) {
    switch (d) {
      case SmsDirection.income:
        return (
          Icons.arrow_downward,
          'Income',
          'Money received (credited to your account)',
          colors.income,
        );
      case SmsDirection.expense:
        return (
          Icons.arrow_upward,
          'Expense',
          'Money spent (debited from your account)',
          colors.expense,
        );
      case SmsDirection.balanceCheck:
        return (
          Icons.info_outline,
          'Balance Check',
          'Informational only — excluded from income/expense totals',
          colors.balance,
        );
    }
  }
}
