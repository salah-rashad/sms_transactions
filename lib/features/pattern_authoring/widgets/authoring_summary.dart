import 'package:flutter/material.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/core/utils/currency.dart';
import 'package:sms_transactions/domain/models/pattern_match.dart';
import 'package:sms_transactions/domain/models/sms_pattern.dart';
import 'package:sms_transactions/domain/models/sms_token.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/step_header.dart';

/// Summary step (FR-014): a live preview of the annotated SMS with every
/// extracted field value and its role clearly labeled.
class AuthoringSummary extends StatelessWidget {
  final String body;
  final PatternMatch? preview;
  final SmsDirection direction;
  final bool isSaving;

  /// Tokens used to derive the preview — their character spans are highlighted
  /// in the sample message body (bold + the field's color).
  final NumericToken? amountToken;
  final NumericToken? balanceToken;
  final TextToken? counterpartyToken;

  const AuthoringSummary({
    super.key,
    required this.body,
    required this.preview,
    required this.direction,
    this.isSaving = false,
    this.amountToken,
    this.balanceToken,
    this.counterpartyToken,
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
                if (amountToken != null)
                  _Field(
                    label: 'Amount',
                    value: formatCurrency(
                      amountToken!.normalizedValue,
                      decimals: 2,
                    ),
                    icon: Icons.payments_outlined,
                    color: direction == SmsDirection.income
                        ? context.appColors.income
                        : context.appColors.expense,
                  ),
                if (balanceToken != null)
                  _Field(
                    label: 'Balance',
                    value: formatCurrency(
                      balanceToken!.normalizedValue,
                      decimals: 2,
                    ),
                    icon: Icons.account_balance_wallet_outlined,
                    color: context.appColors.balance,
                  ),
                _Field(
                  label: 'Direction',
                  value: _directionLabel(direction),
                  icon: _directionIcon(direction),
                  color: scheme.primary,
                ),
                if (counterpartyToken != null)
                  _Field(
                    label: 'Counterparty',
                    value: (counterpartyToken?.rawText.isNotEmpty ?? false)
                        ? counterpartyToken!.rawText
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
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.85),
                height: 1.5,
              ),
              children: _buildBodySpans(
                body,
                baseColor: scheme.onSurface.withValues(alpha: 0.85),
                amountColor: direction == SmsDirection.income
                    ? context.appColors.income
                    : context.appColors.expense,
                balanceColor: context.appColors.balance,
                counterpartyColor: scheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Split [body] into [TextSpan]s, bolding + coloring every range covered by
  /// the selected tokens. Ranges are clamped to the body and overlaps
  /// (first-wins) are skipped so a character is never double-styled.
  List<TextSpan> _buildBodySpans(
    String body, {
    required Color baseColor,
    required Color amountColor,
    required Color balanceColor,
    required Color counterpartyColor,
  }) {
    if (body.isEmpty) {
      return const [TextSpan(text: '(no body)')];
    }

    final ranges = <_Highlight>[];
    if (amountToken != null) {
      ranges.add(
        _Highlight(amountToken!.startIndex, amountToken!.endIndex, amountColor),
      );
    }
    if (balanceToken != null) {
      ranges.add(
        _Highlight(
          balanceToken!.startIndex,
          balanceToken!.endIndex,
          balanceColor,
        ),
      );
    }
    if (counterpartyToken != null) {
      ranges.add(
        _Highlight(
          counterpartyToken!.startIndex,
          counterpartyToken!.endIndex,
          counterpartyColor,
        ),
      );
    }
    ranges.sort((a, b) => a.start.compareTo(b.start));

    final spans = <TextSpan>[];
    var cursor = 0;
    for (final r in ranges) {
      final start = r.start.clamp(0, body.length);
      final end = r.end.clamp(0, body.length);
      if (start < cursor || end <= start) continue;
      if (start > cursor) {
        spans.add(TextSpan(text: body.substring(cursor, start)));
      }
      spans.add(
        TextSpan(
          text: body.substring(start, end),
          style: TextStyle(fontWeight: FontWeight.bold, color: r.color),
        ),
      );
      cursor = end;
    }
    if (cursor < body.length) {
      spans.add(TextSpan(text: body.substring(cursor)));
    }
    return spans;
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

/// A character range in the SMS body to render with [color].
class _Highlight {
  final int start;
  final int end;
  final Color color;

  const _Highlight(this.start, this.end, this.color);
}
