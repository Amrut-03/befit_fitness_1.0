import 'package:equatable/equatable.dart';

/// One drink the user logged.
class WaterEntry extends Equatable {
  const WaterEntry({required this.id, required this.ml, required this.at});

  final String id;
  final int ml;
  final DateTime at;

  @override
  List<Object?> get props => [id, ml, at];
}
