import 'package:fitness_app/core/health/daily_aggregation.dart';
import 'package:fitness_app/core/health/health_platform_service.dart';
import 'package:flutter_test/flutter_test.dart';

RawSample _at(DateTime t, double v) => RawSample(from: t, to: t, value: v);

RawSample _span(DateTime from, DateTime to) =>
    RawSample(from: from, to: to, value: 0);

void main() {
  group('average (heart rate)', () {
    test('averages samples per day, sorted by day', () {
      final readings = DailyAggregation.average([
        _at(DateTime(2026, 11, 9, 23), 70),
        _at(DateTime(2026, 11, 8, 8), 60),
        _at(DateTime(2026, 11, 9, 7), 80),
      ]);

      expect(readings, [
        DailyReading(day: DateTime(2026, 11, 8), value: 60),
        DailyReading(day: DateTime(2026, 11, 9), value: 75),
      ]);
    });

    test('empty input gives no readings', () {
      expect(DailyAggregation.average(const []), isEmpty);
    });
  });

  group('latest (weight)', () {
    test('keeps the last sample of each day', () {
      final readings = DailyAggregation.latest([
        _at(DateTime(2026, 11, 9, 20), 71.2),
        _at(DateTime(2026, 11, 9, 7), 70.4),
        _at(DateTime(2026, 11, 10, 7), 70.9),
      ]);

      expect(readings, [
        DailyReading(day: DateTime(2026, 11, 9), value: 71.2),
        DailyReading(day: DateTime(2026, 11, 10), value: 70.9),
      ]);
    });
  });

  group('sleepHours', () {
    test('credits a night to the day the user woke up', () {
      final readings = DailyAggregation.sleepHours([
        _span(DateTime(2026, 11, 9, 23), DateTime(2026, 11, 10, 6, 30)),
      ]);

      expect(readings, [DailyReading(day: DateTime(2026, 11, 10), value: 7.5)]);
    });

    test('sums HealthKit stage samples and ignores gaps', () {
      final readings = DailyAggregation.sleepHours([
        _span(DateTime(2026, 11, 9, 23), DateTime(2026, 11, 10, 1)), // core
        _span(DateTime(2026, 11, 10, 1), DateTime(2026, 11, 10, 2)), // deep
        // 30 min awake, not sampled
        _span(DateTime(2026, 11, 10, 2, 30), DateTime(2026, 11, 10, 6)),
      ]);

      expect(readings.single.value, 6.5);
    });

    test('merges overlapping samples from two sources', () {
      final readings = DailyAggregation.sleepHours([
        _span(DateTime(2026, 11, 9, 23), DateTime(2026, 11, 10, 6)), // watch
        _span(DateTime(2026, 11, 10, 0), DateTime(2026, 11, 10, 7)), // phone
      ]);

      expect(readings.single.value, 8);
    });

    test('skips zero-length samples', () {
      expect(
        DailyAggregation.sleepHours([
          _span(DateTime(2026, 11, 10, 1), DateTime(2026, 11, 10, 1)),
        ]),
        isEmpty,
      );
    });
  });
}
