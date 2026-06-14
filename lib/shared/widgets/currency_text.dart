import 'package:flutter/material.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/core/utils/currency.dart';

class CurrencyText extends StatelessWidget {
  final double amount;
  final Color color;
  final TextStyle? style;
  final int decimals;
  final String prefix;
  final bool includeCurrency;

  const CurrencyText({
    super.key,
    required this.amount,
    required this.color,
    this.style,
    this.decimals = 2,
    this.prefix = '',
    this.includeCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        style ??
        context.textTheme.titleLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        );

    final formatted = _format(amount);
    final dotIndex = formatted.lastIndexOf('.');

    if (dotIndex == -1) {
      return RichText(
        text: TextSpan(
          text: '$prefix$formatted',
          style: effectiveStyle?.copyWith(color: color),
        ),
      );
    }

    final intPart = '$prefix${formatted.substring(0, dotIndex)}';
    final decPart = formatted.substring(dotIndex);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: intPart,
            style: effectiveStyle?.copyWith(color: color),
          ),
          TextSpan(
            text: decPart,
            style: effectiveStyle?.copyWith(
              color: color.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  String _format(double value) {
    var text = formatCurrency(value, decimals: decimals);
    if (includeCurrency) text += ' EGP';
    return text;
  }
}
