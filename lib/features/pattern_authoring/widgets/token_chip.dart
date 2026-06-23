import 'package:flutter/material.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';

/// One tappable chip representing a numeric or text token from the SMS body
/// (FR-008/029/030). De-emphasized when the token looks non-transactional
/// (OTP/reference/phone) to steer the user toward likely amount/balance chips.
class TokenChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool deEmphasized;
  final TokenRole role;
  final VoidCallback? onTap;

  const TokenChip({
    super.key,
    required this.label,
    this.selected = false,
    this.deEmphasized = false,
    this.role = TokenRole.none,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final colors = context.appColors;

    Color fg;
    Color bg;
    Color border;
    if (selected) {
      switch (role) {
        case TokenRole.amountIncome:
          fg = colors.income;
          bg = colors.income.withValues(alpha: 0.12);
          border = colors.income;
          break;
        case TokenRole.amountExpense:
          fg = colors.expense;
          bg = colors.expense.withValues(alpha: 0.12);
          border = colors.expense;
          break;
        case TokenRole.balance:
          fg = colors.balance;
          bg = colors.balance.withValues(alpha: 0.12);
          border = colors.balance;
          break;
        case TokenRole.counterparty:
          fg = scheme.primary;
          bg = scheme.primary.withValues(alpha: 0.12);
          border = scheme.primary;
          break;
        case TokenRole.none:
          fg = scheme.onPrimary;
          bg = scheme.primary;
          border = scheme.primary;
      }
    } else if (deEmphasized) {
      fg = scheme.onSurfaceVariant.withValues(alpha: 0.5);
      bg = scheme.surfaceContainerHighest.withValues(alpha: 0.4);
      border = scheme.outlineVariant.withValues(alpha: 0.4);
    } else {
      fg = scheme.onSurface;
      bg = scheme.surfaceContainerHighest;
      border = scheme.outlineVariant;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border, width: selected ? 1.4 : 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: fg,
              decoration: deEmphasized && !selected
                  ? TextDecoration.lineThrough
                  : null,
              decorationColor: fg,
            ),
          ),
        ),
      ),
    );
  }
}

enum TokenRole { none, amountIncome, amountExpense, balance, counterparty }

/// A span of text in the SMS body to render as a tappable chip.
class TokenSpan {
  final int startIndex;
  final int endIndex;
  final String label;
  final bool selected;
  final bool deEmphasized;
  final TokenRole role;
  final VoidCallback? onTap;

  const TokenSpan({
    required this.startIndex,
    required this.endIndex,
    required this.label,
    this.selected = false,
    this.deEmphasized = false,
    this.role = TokenRole.none,
    this.onTap,
  });
}

/// Renders an SMS body with token spans as inline tappable chips and the text
/// between them as plain text. Chips follow logical text order and the layout
/// respects the body's base direction (FR-030).
class AnnotatedSmsBody extends StatelessWidget {
  final String body;
  final List<TokenSpan> spans;

  const AnnotatedSmsBody({super.key, required this.body, required this.spans});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final sorted = [...spans]
      ..sort((a, b) => a.startIndex.compareTo(b.startIndex));

    final children = <Widget>[];
    var cursor = 0;
    for (final span in sorted) {
      if (span.startIndex > cursor) {
        children.add(
          Text(
            body.substring(cursor, span.startIndex),
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurface.withValues(alpha: 0.85),
              height: 1.8,
            ),
          ),
        );
      }
      children.add(
        TokenChip(
          label: span.label,
          selected: span.selected,
          deEmphasized: span.deEmphasized,
          role: span.role,
          onTap: span.onTap,
        ),
      );
      cursor = span.endIndex;
    }
    if (cursor < body.length) {
      children.add(
        Text(
          body.substring(cursor),
          style: TextStyle(
            fontSize: 14,
            color: scheme.onSurface.withValues(alpha: 0.85),
            height: 1.8,
          ),
        ),
      );
    }

    return Directionality(
      textDirection: detectBaseDirection(body),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }
}

/// Detects the base direction of a body from the first strong directional
/// character (Arabic → RTL, otherwise LTR) (FR-030). Public so plain-text
/// previews of SMS bodies match the chip-annotated layout's direction.
TextDirection detectBaseDirection(String body) {
  final arabic = RegExp(r'[\u0600-\u06FF]');
  for (final match in arabic.allMatches(body)) {
    final before = body.substring(0, match.start);
    if (!RegExp(r'[A-Za-z]').hasMatch(before)) return TextDirection.rtl;
    return TextDirection.ltr;
  }
  return TextDirection.ltr;
}
