import 'package:flutter/material.dart';
import 'package:sms_transactions/utils/extensions/BuildContext.ext.dart';

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
    if (decimals == 0) {
      final intPart = value.abs().round().toString();
      String text = '${value < 0 ? '-' : ''}${_addCommas(intPart)}';
      if (includeCurrency) {
        text += ' EGP';
      }
      return text;
    }
    final fixed = value.abs().toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final formatted = _addCommas(parts[0]);
    String text = '${value < 0 ? '-' : ''}$formatted.${parts[1]}';
    if (includeCurrency) {
      text += ' EGP';
    }
    return text;
  }

  static String _addCommas(String intPart) {
    final buffer = StringBuffer();
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
      count++;
    }
    return String.fromCharCodes(buffer.toString().codeUnits.reversed);
  }
}
