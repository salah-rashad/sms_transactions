import 'package:flutter/material.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/domain/models/sms_token.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/token_chip.dart';

/// Balance picker step. Used both as the optional running-balance step for
/// income/expense patterns (skip allowed) and as the primary value step for
/// balance-check patterns ([isPrimary] = true; skip hidden by the screen).
class StepBalance extends StatelessWidget {
  final String body;
  final List<NumericToken> tokens;

  /// The previously-picked amount token (income/expense flow). Null when this
  /// step is the primary value step (balance-check flow), where no amount has
  /// been chosen.
  final NumericToken? amount;
  final NumericToken? selected;
  final bool isPrimary;

  /// Called with the chosen balance token, or null when the user skips.
  final ValueChanged<NumericToken?> onSelect;

  const StepBalance({
    super.key,
    required this.body,
    required this.tokens,
    this.amount,
    this.selected,
    required this.onSelect,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isPrimary ? 'Tap the balance' : 'Tap the running balance',
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          isPrimary
              ? 'This message has no transaction amount — only the balance.'
              : 'Optional — skip if this message has no balance.',
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        if (_selectable.isEmpty)
          const _EmptyHint(
            icon: Icons.looks_two_outlined,
            message: 'No numbers to choose from.',
          )
        else
          AnnotatedSmsBody(body: body, spans: _spans),
      ],
    );
  }

  List<NumericToken> get _selectable =>
      tokens.where((t) => t != amount).toList();

  List<TokenSpan> get _spans => [
        for (final t in _selectable)
          TokenSpan(
            startIndex: t.startIndex,
            endIndex: t.endIndex,
            label: t.rawText,
            selected: selected != null && t == selected,
            deEmphasized: t.isLikelyNonTransactional,
            role: TokenRole.balance,
            onTap: () => onSelect(t),
          ),
      ];
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
