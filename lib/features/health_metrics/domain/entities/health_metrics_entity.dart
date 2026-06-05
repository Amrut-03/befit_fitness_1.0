import 'package:equatable/equatable.dart';

enum MetricType { heartRate, weight, sleep }

class HealthMetricEntity extends Equatable {
  final MetricType type;

  final DateTime date;

  final double value;

  final bool isManual;

  const HealthMetricEntity({
    required this.type,

    required this.date,

    required this.value,

    required this.isManual,
  });

  @override
  List<Object?> get props => [type, date, value, isManual];
}
