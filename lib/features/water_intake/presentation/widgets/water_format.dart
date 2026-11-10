/// "250 ml" below a litre, "1.25 L" from a litre up.
String formatWater(int ml) {
  if (ml < 1000) return '$ml ml';
  final litres = ml / 1000;
  final text = litres.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  return '$text L';
}
