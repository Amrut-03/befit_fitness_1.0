/// Lets the water feature quiet the day's hydration reminders once the goal
/// is met, and bring them back if it no longer is (an entry was undone).
abstract class HydrationReminders {
  Future<void> goalReachedToday();

  Future<void> goalNotReachedToday();
}
