import 'package:fitness_app/features/ai_insights/data/models/ai_insight_model.dart';
import 'package:hive/hive.dart';

/// Caches the day's insights so Home calls Gemini at most once per day per
/// user. The box is cleared on logout and account deletion.
class AIInsightsLocalDatasource {
  AIInsightsLocalDatasource(this.box);

  final Box<dynamic> box;

  static const _key = 'daily_insights';

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Insights cached for [uid] on [day], or null.
  /// Insights are cached per [language] code, so switching the app's
  /// language regenerates them instead of showing the old language.
  List<AIInsightModel>? read({
    required String uid,
    required DateTime day,
    String language = 'en',
  }) {
    final raw = box.get(_key);
    if (raw is! Map) return null;
    if (raw['uid'] != uid || raw['day'] != dayKey(day)) return null;
    if ((raw['lang'] ?? 'en') != language) return null;

    final list = raw['insights'];
    if (list is! List) return null;
    return list
        .whereType<Map>()
        .map((m) => AIInsightModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> write({
    required String uid,
    required DateTime day,
    required List<AIInsightModel> insights,
    String language = 'en',
  }) {
    return box.put(_key, {
      'uid': uid,
      'day': dayKey(day),
      'lang': language,
      'insights': insights.map((i) => i.toJson()).toList(),
    });
  }
}
