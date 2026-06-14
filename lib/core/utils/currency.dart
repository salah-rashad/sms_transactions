String _addCommas(String intPart) {
  final buffer = StringBuffer();
  int count = 0;
  for (int i = intPart.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buffer.write(',');
    buffer.write(intPart[i]);
    count++;
  }
  return String.fromCharCodes(buffer.toString().codeUnits.reversed);
}

String formatCurrency(double amount, {int decimals = 2}) {
  if (decimals == 0) {
    final intPart = amount.abs().round().toString();
    return '${amount < 0 ? '-' : ''}${_addCommas(intPart)}';
  }
  final fixed = amount.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  return '${amount < 0 ? '-' : ''}${_addCommas(parts[0])}.${parts[1]}';
}

String formatEgp(double amount, {int decimals = 2}) {
  return '${formatCurrency(amount, decimals: decimals)} EGP';
}
