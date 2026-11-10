import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/workout/data/datasources/remote/workout_remote_datasource.dart';
import 'package:fitness_app/features/workout/data/models/exercise_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FakeFirestore extends Fake implements FirebaseFirestore {}

class _FakeAuth extends Fake implements FirebaseAuth {}

Map<String, dynamic> _exerciseJson(String id) => {
  'exerciseId': id,
  'name': 'Cable Crossover',
  'gifUrl': 'https://static.exercisedb.dev/media/$id.gif',
  'bodyParts': ['chest'],
  'equipments': ['cable'],
  'targetMuscles': ['pectorals'],
  'secondaryMuscles': ['deltoids'],
  'instructions': [
    'Step:1 Set the cable pulleys to chest height.',
    'Step:2 Bring the handles together.',
  ],
};

void main() {
  group('ExerciseModel.fromJson', () {
    test('maps the OSS ExerciseDB v1 shape', () {
      final model = ExerciseModel.fromJson(_exerciseJson('0CXGHya'));

      expect(model.id, '0CXGHya');
      expect(model.bodyPart, 'chest');
      expect(model.target, 'pectorals');
      expect(model.equipment, 'cable');
      expect(model.gifUrl, 'https://static.exercisedb.dev/media/0CXGHya.gif');
      expect(model.instructions, [
        'Set the cable pulleys to chest height.',
        'Bring the handles together.',
      ]);
    });

    test('tolerates missing optional fields', () {
      final model = ExerciseModel.fromJson({
        'exerciseId': 'x',
        'name': 'Plank',
      });

      expect(model.bodyPart, '');
      expect(model.target, '');
      expect(model.gifUrl, isNull);
      expect(model.instructions, isEmpty);
    });
  });

  group('WorkoutRemoteDatasource.getExercises', () {
    late Uri requested;

    WorkoutRemoteDatasource buildWith(http.Response response) {
      return WorkoutRemoteDatasource(
        firestore: _FakeFirestore(),
        auth: _FakeAuth(),
        client: MockClient((request) async {
          requested = request.url;
          return response;
        }),
      );
    }

    test('sends body part + cursor and sends no API key', () async {
      final ds = buildWith(
        http.Response(
          jsonEncode({
            'success': true,
            'meta': {'hasNextPage': true, 'nextCursor': 'next123'},
            'data': [_exerciseJson('a'), _exerciseJson('b')],
          }),
          200,
        ),
      );

      final page = await ds.getExercises(
        limit: 2,
        cursor: 'abc',
        bodyPart: 'Upper Arms',
      );

      expect(requested.host, 'oss.exercisedb.dev');
      expect(requested.path, '/api/v1/exercises');
      expect(requested.queryParameters, {
        'limit': '2',
        'bodyParts': 'upper arms',
        'after': 'abc',
      });
      expect(page.exercises.map((e) => e.id), ['a', 'b']);
      expect(page.nextCursor, 'next123');
      expect(page.hasMore, isTrue);
    });

    test('omits empty filters and reports last page', () async {
      final ds = buildWith(
        http.Response(
          jsonEncode({
            'success': true,
            'meta': {'hasNextPage': false, 'nextCursor': 'ignored'},
            'data': [_exerciseJson('z')],
          }),
          200,
        ),
      );

      final page = await ds.getExercises(bodyPart: '  ');

      expect(requested.queryParameters, {'limit': '20'});
      expect(page.nextCursor, isNull);
      expect(page.hasMore, isFalse);
    });

    test('throws on non-200', () async {
      final ds = buildWith(http.Response('nope', 503));

      expect(ds.getExercises(), throwsException);
    });
  });
}
