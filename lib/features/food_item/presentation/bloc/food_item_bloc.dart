import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fitness_app/features/food_item/domain/usecases/delete_food_item.dart';
import 'package:fitness_app/features/food_item/domain/usecases/get_food_items.dart';
import 'package:fitness_app/features/food_item/domain/usecases/save_food_item.dart';
import 'package:fitness_app/features/food_item/domain/usecases/update_food_item.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_event.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_state.dart';

class FoodItemsBloc extends Bloc<FoodItemsEvent, FoodItemsState> {
  final GetFoodItems getFoodItems;
  final SaveFoodItem saveFoodItem;
  final DeleteFoodItemUseCase deleteFoodItem;
  final UpdateFoodItemUseCase updateFoodItem;
  StreamSubscription? _foodItemsSubscription;

  FoodItemsBloc(
    this.getFoodItems,
    this.saveFoodItem,
    this.deleteFoodItem,
    this.updateFoodItem,
  ) : super(FoodItemsState()) {
    on<LoadFoodItems>(_onLoad);
    on<SaveFoodItems>(_onSaveFoodItem);
    on<FoodItemsUpdated>(_onFoodItemsUpdated);
    on<DeleteFoodItem>(_onDeleteFoodItem);
    on<UpdateFoodItem>(_onUpdateFoodItem);
  }

  Future<void> _onDeleteFoodItem(
    DeleteFoodItem event,
    Emitter<FoodItemsState> emit,
  ) async {
    try {
      await deleteFoodItem(event.id);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to delete food item'));
    }
  }

  void _onFoodItemsUpdated(
    FoodItemsUpdated event,
    Emitter<FoodItemsState> emit,
  ) {
    emit(state.copyWith(isLoading: false, items: event.items));
  }

  Future<void> _onLoad(
    LoadFoodItems event,
    Emitter<FoodItemsState> emit,
  ) async {
    if (_foodItemsSubscription != null) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    _foodItemsSubscription = getFoodItems().listen(
      (items) {
        add(FoodItemsUpdated(items));
      },

      onError: (_) {
        emit(
          state.copyWith(isLoading: false, error: 'Failed to load food items'),
        );
      },
    );
  }

  Future<void> _onSaveFoodItem(
    SaveFoodItems event,
    Emitter<FoodItemsState> emit,
  ) async {
    try {
      await saveFoodItem(event.item);
    } catch (e) {
      emit(state.copyWith(error: "Failed to save"));
    }
  }

  Future<void> _onUpdateFoodItem(
    UpdateFoodItem event,
    Emitter<FoodItemsState> emit,
  ) async {
    try {
      await updateFoodItem(event.item);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update food item'));
    }
  }

  @override
  Future<void> close() {
    _foodItemsSubscription?.cancel();

    return super.close();
  }
}
