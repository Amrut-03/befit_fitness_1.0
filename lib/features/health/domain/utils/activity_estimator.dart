class ActivityEstimator {
  static const double walkingMet = 4.0;

  static const double walkingSpeedKmh = 5.0;

  static double _strideLengthMeters({
    required double heightCm,
    required String gender,
  }) {
    final factor = gender == 'Female' ? 0.413 : 0.415;
    return (heightCm / 100) * factor;
  }

  static double _distanceKm({
    required int steps,
    required double strideMeters,
  }) {
    return (steps * strideMeters) / 1000;
  }

  static double calories({
    required int steps,
    required double weightKg,
    required double heightCm,
    String gender = 'Male',
  }) {
    if (steps <= 0 || weightKg <= 0) return 0;

    final stride = _strideLengthMeters(heightCm: heightCm, gender: gender);
    final distanceKm = _distanceKm(steps: steps, strideMeters: stride);
    final hours = distanceKm / walkingSpeedKmh;

    return walkingMet * weightKg * hours;
  }

  static int moveMinutes({
    required int steps,
    required double heightCm,
    String gender = 'Male',
  }) {
    if (steps <= 0) return 0;

    final stride = _strideLengthMeters(heightCm: heightCm, gender: gender);
    final distanceKm = _distanceKm(steps: steps, strideMeters: stride);

    return (distanceKm / walkingSpeedKmh * 60).round();
  }
}