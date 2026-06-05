import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';

abstract class FoodItemsEvent extends Equatable {
  const FoodItemsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFoodItems extends FoodItemsEvent {
  const LoadFoodItems();
}

class DeleteFoodItem extends FoodItemsEvent {
  final String id;

  const DeleteFoodItem(this.id);

  @override
  List<Object?> get props => [id];
}

class SaveFoodItems extends FoodItemsEvent {
  final FoodItemEntity item;

  const SaveFoodItems(this.item);

  @override
  List<Object?> get props => [item];
}

class FoodItemsUpdated extends FoodItemsEvent {
  final List<FoodItemEntity> items;

  const FoodItemsUpdated(this.items);

  @override
  List<Object?> get props => [items];
}

class UpdateFoodItem extends FoodItemsEvent {
  final FoodItemEntity item;

  const UpdateFoodItem(this.item);

  @override
  List<Object?> get props => [item];
}
