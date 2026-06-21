import 'package:flutter/material.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/domain/models/sms_token.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/token_chip.dart';

/// Step 4 (FR-012): the user taps one or more consecutive text tokens to mark
/// the counterparty name. Numeric tokens are not selectable here.
class StepCounterparty extends StatelessWidget {
  final String body;
  final List<TextToken> tokens;
  final List<TextToken> selectedTokens;

  /// Called when the user taps a token to toggle it in/out of the selection.
  final ValueChanged<TextToken> onToggle;

  const StepCounterparty({
    super.key,
    required this.body,
    required this.tokens,
    this.selectedTokens = const [],
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Counterparty (optional)', style: context.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Tap one or more words to mark the counterparty name.',
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        if (tokens.isEmpty)
          Row(
            children: [
              Icon(Icons.text_fields, size: 20, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'No text tokens detected. Tap Skip.',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                ),
              ),
            ],
          )
        else
          AnnotatedSmsBody(body: body, spans: _spans),
      ],
    );
  }

  List<TokenSpan> get _spans => [
        for (final t in tokens)
          TokenSpan(
            startIndex: t.startIndex,
            endIndex: t.endIndex,
            label: t.rawText,
            selected: selectedTokens.contains(t),
            role: TokenRole.counterparty,
            onTap: () => onToggle(t),
          ),
      ];
}
