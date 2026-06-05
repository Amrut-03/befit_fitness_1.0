import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fitness_app/features/streak/domain/entities/streak_entity.dart';

class StreakModel extends StreakEntity {
  const StreakModel({
    required super.currentStreak,

    required super.lastActiveDate,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['streak'] ?? 0,

      lastActiveDate: json['lastActiveDate'] != null
          ? (json['lastActiveDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streak': currentStreak,

      'lastActiveDate': lastActiveDate != null
          ? Timestamp.fromDate(lastActiveDate!)
          : null,
    };
  }

  factory StreakModel.fromEntity(StreakEntity entity) {
    return StreakModel(
      currentStreak: entity.currentStreak,

      lastActiveDate: entity.lastActiveDate,
    );
  }
}
