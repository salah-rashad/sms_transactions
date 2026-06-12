String formatCurrency(double amount) {
  final fixed = amount.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final intPart = parts[0];
  final decPart = parts[1];

  final buffer = StringBuffer();
  int count = 0;
  for (int i = intPart.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buffer.write(',');
    buffer.write(intPart[i]);
    count++;
  }

  final formatted = String.fromCharCodes(buffer.toString().codeUnits.reversed);
  return '${amount < 0 ? '-' : ''}$formatted.$decPart';
}

String formatEgp(double amount, {int decimals = 2}) {
  if (decimals == 0) {
    final intPart = amount.abs().round().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
      count++;
    }
    final formatted = String.fromCharCodes(buffer.toString().codeUnits.reversed);
    return '${amount < 0 ? '-' : ''}$formatted EGP';
  }
  return '${formatCurrency(amount)} EGP';
}
