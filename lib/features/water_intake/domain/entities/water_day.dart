import 'package:equatable/equatable.dart';

import 'water_entry.dart';

/// Water logged on one calendar day.
class WaterDay extends Equatable {
  const WaterDay({
    required this.day,
    required this.goalMl,
    this.entries = const [],
  });

  /// Local midnight.
  final DateTime day;

  /// The goal in effect that day, so past days keep their own target.
  final int goalMl;

  /// Oldest first.
  final List<WaterEntry> entries;

  int get totalMl => entries.fold(0, (sum, e) => sum + e.ml);

  double get progress => goalMl <= 0 ? 0 : (totalMl / goalMl).clamp(0, 1);

  bool get goalReached => goalMl > 0 && totalMl >= goalMl;

  @override
  List<Object?> get props => [day, goalMl, entries];
}
