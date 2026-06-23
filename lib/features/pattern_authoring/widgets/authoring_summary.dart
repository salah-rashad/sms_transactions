import 'package:flutter/material.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/core/utils/currency.dart';
import 'package:sms_transactions/domain/models/pattern_match.dart';
import 'package:sms_transactions/domain/models/sms_pattern.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/step_header.dart';

/// Summary step (FR-014): a live preview of the annotated SMS with every
/// extracted field value and its role clearly labeled.
class AuthoringSummary extends StatelessWidget {
  final String body;
  final PatternMatch? preview;
  final SmsDirection direction;
  final bool isSaving;

  const AuthoringSummary({
    super.key,
    required this.body,
    required this.preview,
    required this.direction,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepHeader(
          icon: Icons.fact_check_outlined,
          title: 'Review & save',
          subtitle: 'Here is how this sender will be parsed.',
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: scheme.surfaceContainerHighest,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (preview?.amount != null)
                  _Field(
                    label: 'Amount',
                    value: formatCurrency(preview!.amount!, decimals: 2),
                    icon: Icons.payments_outlined,
                    color: direction == SmsDirection.income
                        ? context.appColors.income
                        : context.appColors.expense,
                  ),
                if (preview?.balance != null)
                  _Field(
                    label: 'Balance',
                    value: formatCurrency(preview!.balance!, decimals: 2),
                    icon: Icons.account_balance_wallet_outlined,
                    color: context.appColors.balance,
                  ),
                _Field(
                  label: 'Direction',
                  value: _directionLabel(direction),
                  icon: _directionIcon(direction),
                  color: scheme.primary,
                ),
                if (preview?.counterparty != null)
                  _Field(
                    label: 'Counterparty',
                    value: (preview?.counterparty?.isNotEmpty ?? false)
                        ? preview!.counterparty!
                        : '—',
                    icon: Icons.person_outline,
                    color: scheme.primary,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sample message:',
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            body.isEmpty ? '(no body)' : body,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurface.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  static String _directionLabel(SmsDirection d) {
    switch (d) {
      case SmsDirection.income:
        return 'Income';
      case SmsDirection.expense:
        return 'Expense';
      case SmsDirection.balanceCheck:
        return 'Balance Check';
      case SmsDirection.ignore:
        return 'Not a transaction';
    }
  }

  static IconData _directionIcon(SmsDirection d) {
    switch (d) {
      case SmsDirection.income:
        return Icons.arrow_downward;
      case SmsDirection.expense:
        return Icons.arrow_upward;
      case SmsDirection.balanceCheck:
        return Icons.info_outline;
      case SmsDirection.ignore:
        return Icons.block_flipped;
    }
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _Field({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
