import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';

class FoodItemsState extends Equatable {
  final bool isLoading;
  final List<FoodItemEntity> items;
  final String? error;

  const FoodItemsState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  FoodItemsState copyWith({
    bool? isLoading,
    List<FoodItemEntity>? items,
    String? error,
  }) {
    return FoodItemsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, items, error];
}
