String formatCurrencyIdr(num value) {
  final text = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final reverseIndex = text.length - i;
    buffer.write(text[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }
  return 'Rp ${buffer.toString()}';
}

String formatLiters(num value) {
  final isWhole = value % 1 == 0;
  final formatted = isWhole ? value.toInt().toString() : value.toStringAsFixed(1);
  return '$formatted L';
}

String formatLitersValue(num value) {
  final isWhole = value % 1 == 0;
  return isWhole ? value.toInt().toString() : value.toStringAsFixed(1);
}
