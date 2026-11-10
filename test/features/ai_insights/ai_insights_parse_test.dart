import 'package:fitness_app/features/ai_insights/data/datasources/remote/ai_insights_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AIInsightsRemoteDatasource.parseInsights', () {
    test('parses structured JSON and caps at four', () {
      const json = '''
      [
        {"emoji":"🔥","title":"On fire","message":"Great step count today."},
        {"emoji":"💪","title":"Strong","message":"Keep the streak alive."},
        {"emoji":"💧","title":"Hydrate","message":"Drink water after walks."},
        {"emoji":"⚡","title":"Energy","message":"Consistency builds results."},
        {"emoji":"🎯","title":"Extra","message":"Should be dropped."}
      ]''';

      final insights = AIInsightsRemoteDatasource.parseInsights(json);

      expect(insights, hasLength(4));
      expect(insights.first.emoji, '🔥');
      expect(insights.first.title, 'On fire');
    });

    test('skips malformed and empty entries', () {
      final insights = AIInsightsRemoteDatasource.parseInsights(
        '[{"emoji":"🔥","title":"A","message":""}, "junk", {"message":"Ok"}]',
      );

      expect(insights.map((i) => i.message), ['Ok']);
      expect(insights.single.emoji, '🤖');
    });

    test('throws on empty or non-array output', () {
      expect(
        () => AIInsightsRemoteDatasource.parseInsights(null),
        throwsFormatException,
      );
      expect(
        () => AIInsightsRemoteDatasource.parseInsights('{"a":1}'),
        throwsFormatException,
      );
    });
  });
}
