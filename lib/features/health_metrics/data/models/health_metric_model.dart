import '../../domain/entities/health_metrics_entity.dart';

class HealthMetricModel extends HealthMetricEntity {
  const HealthMetricModel({
    required super.type,

    required super.date,

    required super.value,

    required super.isManual,
  });

  factory HealthMetricModel.fromJson(Map<String, dynamic> json) {
    return HealthMetricModel(
      type: MetricType.values.firstWhere((e) => e.name == json['type']),

      date: DateTime.parse(json['date'].toString()),

      value: (json['value'] as num).toDouble(),

      isManual: json['isManual'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,

      'date': date.toIso8601String(),

      'value': value,

      'isManual': isManual,
    };
  }
}
