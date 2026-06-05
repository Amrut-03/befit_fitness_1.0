import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_history_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';

class DietState extends Equatable {
  final bool isLoading;
  final List<DietPlanEntity> plans;
  final String? error;
  final List<DietHistoryEntity> history;

  const DietState({
    this.isLoading = false,
    this.plans = const [],
    this.error,
    this.history = const [],
  });

  factory DietState.initial() {
    return const DietState();
  }

  DietState copyWith({
    bool? isLoading,
    List<DietHistoryEntity>? history,
    List<DietPlanEntity>? plans,
    bool removeActivePlan = false,
    String? error,
    bool clearError = false,
  }) {
    return DietState(
      isLoading: isLoading ?? this.isLoading,

      plans: plans ?? this.plans,

      history: history ?? this.history,

      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, plans, error, history];
}
