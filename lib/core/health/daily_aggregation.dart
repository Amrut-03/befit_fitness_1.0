import 'health_platform_service.dart';

/// A raw sample from the health store, reduced to what aggregation needs.
class RawSample {
  const RawSample({required this.from, required this.to, required this.value});

  final DateTime from;
  final DateTime to;
  final double value;
}

/// Pure functions that turn raw samples into one value per day.
abstract final class DailyAggregation {
  static DateTime _day(DateTime t) {
    final l = t.toLocal();
    return DateTime(l.year, l.month, l.day);
  }

  static List<DailyReading> _sorted(Map<DateTime, double> byDay) {
    final days = byDay.keys.toList()..sort();
    return [for (final d in days) DailyReading(day: d, value: byDay[d]!)];
  }

  /// Heart rate: mean bpm of all samples taken that day.
  static List<DailyReading> average(List<RawSample> samples) {
    final sums = <DateTime, double>{};
    final counts = <DateTime, int>{};
    for (final s in samples) {
      final d = _day(s.from);
      sums[d] = (sums[d] ?? 0) + s.value;
      counts[d] = (counts[d] ?? 0) + 1;
    }
    return _sorted({
      for (final d in sums.keys)
        d: double.parse((sums[d]! / counts[d]!).toStringAsFixed(1)),
    });
  }

  /// Weight: the most recent sample of each day.
  static List<DailyReading> latest(List<RawSample> samples) {
    final latest = <DateTime, RawSample>{};
    for (final s in samples) {
      final d = _day(s.from);
      final current = latest[d];
      if (current == null || s.from.isAfter(current.from)) latest[d] = s;
    }
    return _sorted({for (final e in latest.entries) e.key: e.value.value});
  }

  /// Sleep: total hours asleep, credited to the day the user woke up.
  ///
  /// Uses each sample's duration, so it works for Health Connect sessions and
  /// for HealthKit stage samples (core/deep/REM) alike. Overlapping samples
  /// (e.g. two sources) are merged so time isn't counted twice.
  static List<DailyReading> sleepHours(List<RawSample> samples) {
    final sorted = samples.where((s) => s.to.isAfter(s.from)).toList()
      ..sort((a, b) => a.from.compareTo(b.from));

    // Merge overlapping intervals.
    final merged = <(DateTime, DateTime)>[];
    for (final s in sorted) {
      if (merged.isNotEmpty && !s.from.isAfter(merged.last.$2)) {
        final (start, end) = merged.last;
        merged.last = (start, s.to.isAfter(end) ? s.to : end);
      } else {
        merged.add((s.from, s.to));
      }
    }

    final minutes = <DateTime, double>{};
    for (final (start, end) in merged) {
      final d = _day(end);
      minutes[d] = (minutes[d] ?? 0) + end.difference(start).inSeconds / 60;
    }

    return _sorted({
      for (final e in minutes.entries)
        e.key: double.parse((e.value / 60).toStringAsFixed(1)),
    });
  }
}
