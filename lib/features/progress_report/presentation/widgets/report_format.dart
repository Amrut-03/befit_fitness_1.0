import 'package:intl/intl.dart';

import '../../domain/entities/weekly_report.dart';

/// "This week", "Last week", or "3 – 9 Nov".
String weekLabel(WeekRange week, DateTime now) {
  final current = WeekRange.of(now);
  if (week == current) return 'This week';
  if (week == current.shift(-1)) return 'Last week';
  return weekDates(week);
}

/// "10 – 16 Nov", or "27 Oct – 2 Nov" across months.
String weekDates(WeekRange week) {
  final s = week.start, e = week.end;
  return s.month == e.month
      ? '${s.day} – ${DateFormat('d MMM').format(e)}'
      : '${DateFormat('d MMM').format(s)} – ${DateFormat('d MMM').format(e)}';
}

/// "+0.4 kg", "−1.2 kg", "±0 kg".
String signedKg(double kg) {
  if (kg.abs() < 0.05) return '±0 kg';
  final v = kg.abs().toStringAsFixed(1);
  return kg > 0 ? '+$v kg' : '−$v kg';
}

String kg(double v) =>
    '${v == v.roundToDouble() ? v.toInt() : v.toStringAsFixed(1)} kg';
