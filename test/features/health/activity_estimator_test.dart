import 'package:fitness_app/features/health/domain/utils/activity_estimator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActivityEstimator.calories', () {
    test('returns 0 for no steps or no weight', () {
      expect(
        ActivityEstimator.calories(steps: 0, weightKg: 70, heightCm: 175),
        0,
      );
      expect(
        ActivityEstimator.calories(steps: 1000, weightKg: 0, heightCm: 175),
        0,
      );
    });

    test('uses MET × weight × hours walked', () {
      // 10,000 steps × (1.75 m × 0.415) = 7.2625 km → 1.4525 h at 5 km/h.
      final kcal = ActivityEstimator.calories(
        steps: 10000,
        weightKg: 70,
        heightCm: 175,
      );
      expect(kcal, closeTo(4.0 * 70 * 1.4525, 1e-9));
    });

    test('uses a shorter stride for women', () {
      final male = ActivityEstimator.calories(
        steps: 10000,
        weightKg: 70,
        heightCm: 170,
      );
      final female = ActivityEstimator.calories(
        steps: 10000,
        weightKg: 70,
        heightCm: 170,
        gender: 'Female',
      );
      expect(female, lessThan(male));
    });
  });

  group('ActivityEstimator.moveMinutes', () {
    test('returns 0 for no steps', () {
      expect(ActivityEstimator.moveMinutes(steps: 0, heightCm: 175), 0);
    });

    test('rounds walking time to whole minutes', () {
      // 7.2625 km at 5 km/h = 87.15 min.
      expect(ActivityEstimator.moveMinutes(steps: 10000, heightCm: 175), 87);
    });
  });
}
