import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_history_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';

abstract class DietEvent extends Equatable {
  const DietEvent();

  @override
  List<Object?> get props => [];
}

class LoadDietPlans extends DietEvent {}

class SaveDietPlanEvent extends DietEvent {
  final DietPlanEntity plan;

  const SaveDietPlanEvent(this.plan);

  @override
  List<Object?> get props => [plan];
}

class DietPlansUpdated extends DietEvent {
  final List<DietPlanEntity> plans;

  const DietPlansUpdated(this.plans);

  @override
  List<Object?> get props => [plans];
}

class DeleteDietPlanEvent extends DietEvent {
  final String id;

  const DeleteDietPlanEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateMealStatusEvent extends DietEvent {
  final String planId;
  final List<MealEntity> meals;

  const UpdateMealStatusEvent({required this.planId, required this.meals});

  @override
  List<Object?> get props => [planId, meals];
}

class SetActiveDietPlanEvent extends DietEvent {
  final String planId;

  const SetActiveDietPlanEvent(this.planId);

  @override
  List<Object?> get props => [planId];
}

class LoadDietHistory extends DietEvent {}

class DietHistoryUpdated extends DietEvent {
  final List<DietHistoryEntity> history;

  const DietHistoryUpdated(this.history);
}
