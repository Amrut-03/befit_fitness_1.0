/// Pure streak rules based on **local calendar days**, not 24-hour windows.
/// For example, 11 PM → 8 AM the next morning counts as the next day.
class StreakCalculator {
  StreakCalculator._();

  static DateTime _day(DateTime d) {
    final local = d.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Whole calendar days between [from] and [to] in local time. Uses UTC
  /// date arithmetic so DST shifts (23h/25h days) don't skew the count.
  static int calendarDaysBetween(DateTime from, DateTime to) {
    final a = _day(from), b = _day(to);
    return DateTime.utc(
      b.year,
      b.month,
      b.day,
    ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
  }

  /// The streak after recording activity at [now], or null if activity was
  /// already recorded today (no write needed).
  static int? next({
    required int current,
    required DateTime? lastActive,
    required DateTime now,
  }) {
    if (lastActive == null) return 1;

    final gap = calendarDaysBetween(lastActive, now);
    if (gap <= 0) return null; // same day (or clock skew)
    if (gap == 1) return current + 1;
    return 1; // missed at least one day
  }

  /// The streak to display at [now]: a stored streak whose last activity was
  /// before yesterday is already broken and shows as 0.
  static int effective({
    required int stored,
    required DateTime? lastActive,
    required DateTime now,
  }) {
    if (lastActive == null) return 0;
    return calendarDaysBetween(lastActive, now) <= 1 ? stored : 0;
  }
}
