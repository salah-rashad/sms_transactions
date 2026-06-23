import 'package:flutter/material.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/domain/models/sms_token.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/step_header.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/token_chip.dart';

/// Step 1 (FR-008/009): renders the SMS body with every numeric token as a
/// tappable chip; the user taps exactly one to mark the transaction amount.
/// Likely-non-transactional tokens (OTP/reference/phone) are de-emphasized.
class StepAmount extends StatelessWidget {
  final String body;
  final List<NumericToken> tokens;
  final NumericToken? selected;
  final bool isIncome;

  /// Called when the user taps an amount chip.
  final ValueChanged<NumericToken> onSelect;

  const StepAmount({
    super.key,
    required this.body,
    required this.tokens,
    this.selected,
    required this.onSelect,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepHeader(
          icon: Icons.payments_outlined,
          title: 'Tap the transaction amount',
          subtitle:
              'De-emphasized numbers look like OTPs, references, or phone numbers.',
        ),
        const SizedBox(height: 16),
        _tokenBody(context),
      ],
    );
  }

  Widget _tokenBody(BuildContext context) {
    if (tokens.isEmpty) {
      return _EmptyHint(
        icon: Icons.numbers_outlined,
        message: 'No numbers detected in this message.',
      );
    }
    final spans = [
      for (final t in tokens)
        TokenSpan(
          startIndex: t.startIndex,
          endIndex: t.endIndex,
          label: t.rawText,
          selected: selected != null && t == selected,
          deEmphasized: t.isLikelyNonTransactional,
          role: isIncome ? TokenRole.amountIncome : TokenRole.amountExpense,
          onTap: () => onSelect(t),
        ),
    ];
    return AnnotatedSmsBody(body: body, spans: spans);
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyHint({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            message,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
