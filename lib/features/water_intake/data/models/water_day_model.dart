import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/water_day.dart';
import '../../domain/entities/water_entry.dart';

/// Firestore shape of `users/{uid}/waterIntake/{yyyy-MM-dd}`:
/// `{date: Timestamp, goalMl: int, entries: [{id, ml, at: epochMillis}]}`.
///
/// `at` is stored as an int so an entry map read back is byte-identical to
/// the one written, which `FieldValue.arrayRemove` needs to match it.
abstract final class WaterDayModel {
  static Map<String, dynamic> entryToMap(WaterEntry e) => {
    'id': e.id,
    'ml': e.ml,
    'at': e.at.millisecondsSinceEpoch,
  };

  static WaterEntry? entryFromMap(Object? raw) {
    if (raw is! Map) return null;
    final ml = raw['ml'];
    final at = raw['at'];
    if (ml is! num || at is! num) return null;
    return WaterEntry(
      id: raw['id']?.toString() ?? '$at',
      ml: ml.toInt(),
      at: DateTime.fromMillisecondsSinceEpoch(at.toInt()),
    );
  }

  static WaterDay fromJson(
    Map<String, dynamic>? json, {
    required DateTime day,
    required int fallbackGoalMl,
  }) {
    final entries =
        ((json?['entries'] as List?) ?? const [])
            .map(entryFromMap)
            .whereType<WaterEntry>()
            .toList()
          ..sort((a, b) => a.at.compareTo(b.at));

    return WaterDay(
      day: day,
      goalMl: (json?['goalMl'] as num?)?.toInt() ?? fallbackGoalMl,
      entries: entries,
    );
  }

  static DateTime? dayOf(Map<String, dynamic> json) {
    final date = json['date'];
    if (date is! Timestamp) return null;
    final d = date.toDate();
    return DateTime(d.year, d.month, d.day);
  }
}
