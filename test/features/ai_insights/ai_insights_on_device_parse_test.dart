import 'package:fitness_app/features/ai_insights/data/datasources/on_device/ai_insights_on_device_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parse = AIInsightsOnDeviceDatasource.parseLenient;

  test('finds the array inside a preamble and code fence', () {
    final out = parse(
      'Here you go:\n```json\n'
      '[{"emoji":"🔥","title":"On fire","message":"Great day."}]\n```',
    );
    expect(out.single.title, 'On fire');
  });

  test('recovers whole objects from a truncated array', () {
    final out = parse(
      '[{"emoji":"🔥","title":"A","message":"One."},'
      '{"emoji":"💧","title":"B","message":"Two."},'
      '{"emoji":"⚡","title":"C","mess',
    );
    expect(out.map((i) => i.title), ['A', 'B']);
  });

  test('caps at four and drops empty messages', () {
    final items = [
      for (var i = 0; i < 6; i++)
        '{"title":"T$i","message":"${i == 0 ? '' : 'M$i'}"}',
    ];
    final out = parse('[${items.join(',')}');
    expect(out.map((i) => i.title), ['T1', 'T2', 'T3', 'T4']);
  });

  test('plain prose yields nothing', () {
    expect(parse('Keep walking and drink water.'), isEmpty);
  });
}
