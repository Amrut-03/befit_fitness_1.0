import '../entities/weekly_report.dart';

/// A dated value from any source (weigh-ins, logs).
typedef Dated<T> = ({DateTime at, T value});

/// Pure weekly-report maths, kept free of data sources for testing.
abstract final class ReportCalculator {
  static const trendWeeks = 8;

  /// Average weight per week for the [trendWeeks] weeks ending at [week].
  static List<WeeklyWeight> weightTrend(
    List<Dated<double>> weighIns,
    WeekRange week,
  ) {
    final result = <WeeklyWeight>[];
    for (var i = trendWeeks - 1; i >= 0; i--) {
      final w = week.shift(-i);
      final values = [
        for (final p in weighIns)
          if (w.contains(p.at) && p.value > 0) p.value,
      ];
      if (values.isEmpty) continue;
      final avg = values.reduce((a, b) => a + b) / values.length;
      result.add(
        WeeklyWeight(
          weekStart: w.start,
          avgKg: double.parse(avg.toStringAsFixed(1)),
        ),
      );
    }
    return result;
  }

  /// This week's average minus the previous week's, if both have data.
  static double? weightChange(List<WeeklyWeight> trend, WeekRange week) {
    WeeklyWeight? at(DateTime start) {
      for (final w in trend) {
        if (w.weekStart == start) return w;
      }
      return null;
    }

    final now = at(week.start);
    final before = at(week.shift(-1).start);
    if (now == null || before == null) return null;
    return double.parse((now.avgKg - before.avgKg).toStringAsFixed(1));
  }

  /// The most recent weigh-in on or before the end of [week].
  static double? latestWeight(List<Dated<double>> weighIns, WeekRange week) {
    Dated<double>? latest;
    final cutoff = week.end.add(const Duration(days: 1));
    for (final p in weighIns) {
      if (p.at.isBefore(cutoff) &&
          (latest == null || p.at.isAfter(latest.at))) {
        latest = p;
      }
    }
    return latest?.value;
  }

  /// One [MacroDay] per day. The nutrition log wins; a day without one
  /// falls back to the largest completed diet plan recorded that day.
  static List<MacroDay> macroDays({
    required WeekRange week,
    required List<MacroDay> logged,
    required List<MacroDay> completedPlans,
  }) {
    MacroDay? find(List<MacroDay> list, DateTime day) {
      MacroDay? best;
      for (final m in list) {
        if (m.day == day && (best == null || m.calories > best.calories)) {
          best = m;
        }
      }
      return best;
    }

    return [
      for (final day in week.days)
        find(logged, day) ?? find(completedPlans, day) ?? MacroDay(day: day),
    ];
  }

  /// How close one day is to the goals: for each macro
  /// `1 − |eaten − goal| / goal` (floored at 0), averaged. 100 = exactly on
  /// target; eating double or nothing scores 0 for that macro.
  static double dayAdherence(MacroDay d, MacroGoals g) {
    double score(double eaten, double goal) =>
        (1 - (eaten - goal).abs() / goal).clamp(0, 1).toDouble();
    return (score(d.protein, g.protein) +
            score(d.carbs, g.carbs) +
            score(d.fat, g.fat)) /
        3 *
        100;
  }

  /// Mean adherence over logged days; null when none or goals are unset.
  static double? weekAdherence(List<MacroDay> days, MacroGoals? goals) {
    if (goals == null || !goals.isSet) return null;
    final logged = days.where((d) => d.logged).toList();
    if (logged.isEmpty) return null;
    final sum = logged.fold<double>(0, (s, d) => s + dayAdherence(d, goals));
    return double.parse((sum / logged.length).toStringAsFixed(0));
  }

  /// Days of [week] up to and including [today] (7 for past weeks, 0 for
  /// future ones).
  static int daysElapsed(WeekRange week, DateTime today) {
    final t = DateTime(today.year, today.month, today.day);
    if (t.isBefore(week.start)) return 0;
    if (t.isAfter(week.end)) return 7;
    return t.difference(week.start).inDays + 1;
  }
}
