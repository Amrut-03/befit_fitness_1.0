import 'package:equatable/equatable.dart';

class NotificationSettings extends Equatable {
  final bool workoutReminder;
  final int workoutHour;
  final int workoutMinute;
  final bool waterReminder;
  final bool mealReminder;
  final bool streakReminder;

  const NotificationSettings({
    this.workoutReminder = true,
    this.workoutHour = 7,
    this.workoutMinute = 0,
    this.waterReminder = true,
    this.mealReminder = false,
    this.streakReminder = true,
  });

  bool get anyEnabled =>
      workoutReminder || waterReminder || mealReminder || streakReminder;

  NotificationSettings copyWith({
    bool? workoutReminder,
    int? workoutHour,
    int? workoutMinute,
    bool? waterReminder,
    bool? mealReminder,
    bool? streakReminder,
  }) {
    return NotificationSettings(
      workoutReminder: workoutReminder ?? this.workoutReminder,
      workoutHour: workoutHour ?? this.workoutHour,
      workoutMinute: workoutMinute ?? this.workoutMinute,
      waterReminder: waterReminder ?? this.waterReminder,
      mealReminder: mealReminder ?? this.mealReminder,
      streakReminder: streakReminder ?? this.streakReminder,
    );
  }

  Map<String, dynamic> toMap() => {
    'workoutReminder': workoutReminder,
    'workoutHour': workoutHour,
    'workoutMinute': workoutMinute,
    'waterReminder': waterReminder,
    'mealReminder': mealReminder,
    'streakReminder': streakReminder,
  };

  factory NotificationSettings.fromMap(Map<dynamic, dynamic> m) {
    const d = NotificationSettings();
    return NotificationSettings(
      workoutReminder: m['workoutReminder'] as bool? ?? d.workoutReminder,
      workoutHour: m['workoutHour'] as int? ?? d.workoutHour,
      workoutMinute: m['workoutMinute'] as int? ?? d.workoutMinute,
      waterReminder: m['waterReminder'] as bool? ?? d.waterReminder,
      mealReminder: m['mealReminder'] as bool? ?? d.mealReminder,
      streakReminder: m['streakReminder'] as bool? ?? d.streakReminder,
    );
  }

  @override
  List<Object?> get props => [
    workoutReminder,
    workoutHour,
    workoutMinute,
    waterReminder,
    mealReminder,
    streakReminder,
  ];
}
