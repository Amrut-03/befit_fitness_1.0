import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';
import 'package:fitness_app/features/food_item/domain/usecases/delete_food_item.dart';
import 'package:fitness_app/features/food_item/domain/usecases/get_food_items.dart';
import 'package:fitness_app/features/food_item/domain/usecases/save_food_item.dart';
import 'package:fitness_app/features/food_item/domain/usecases/update_food_item.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_bloc.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_event.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Get extends Mock implements GetFoodItems {}

class _Save extends Mock implements SaveFoodItem {}

class _Delete extends Mock implements DeleteFoodItemUseCase {}

class _Update extends Mock implements UpdateFoodItemUseCase {}

void main() {
  late _Get getItems;
  late _Save save;

  const item = FoodItemEntity(id: 'f1', name: 'Rice', source: 'manual');
  const cached = FoodItemEntity(id: 'f0', name: 'Cached', source: 'manual');

  setUpAll(() => registerFallbackValue(item));

  setUp(() {
    getItems = _Get();
    save = _Save();
  });

  FoodItemsBloc build() => FoodItemsBloc(getItems, save, _Delete(), _Update());

  blocTest<FoodItemsBloc, FoodItemsState>(
    'load emits loading, then cache, then live items',
    setUp: () => when(() => getItems()).thenAnswer(
      (_) => Stream.fromIterable([
        [cached],
        [cached, item],
      ]),
    ),
    build: build,
    act: (b) => b.add(const LoadFoodItems()),
    expect: () => const [
      FoodItemsState(isLoading: true),
      FoodItemsState(items: [cached]),
      FoodItemsState(items: [cached, item]),
    ],
  );

  blocTest<FoodItemsBloc, FoodItemsState>(
    'a second load while subscribed is ignored',
    setUp: () => when(() => getItems()).thenAnswer((_) => Stream.value([item])),
    build: build,
    act: (b) async {
      b.add(const LoadFoodItems());
      await Future<void>.delayed(Duration.zero);
      b.add(const LoadFoodItems());
    },
    verify: (_) => verify(() => getItems()).called(1),
  );

  blocTest<FoodItemsBloc, FoodItemsState>(
    'stream error → error state, and the next load retries',
    setUp: () {
      var call = 0;
      when(() => getItems()).thenAnswer(
        (_) => ++call == 1
            ? Stream.error(Exception('offline'))
            : Stream.value([item]),
      );
    },
    build: build,
    act: (b) async {
      b.add(const LoadFoodItems());
      await Future<void>.delayed(Duration.zero);
      b.add(const LoadFoodItems());
    },
    expect: () => const [
      FoodItemsState(isLoading: true),
      FoodItemsState(error: 'Failed to load food items'),
      FoodItemsState(isLoading: true),
      FoodItemsState(items: [item]),
    ],
  );

  blocTest<FoodItemsBloc, FoodItemsState>(
    'save failure surfaces an error',
    setUp: () => when(() => save(any())).thenThrow(Exception()),
    build: build,
    act: (b) => b.add(const SaveFoodItems(item)),
    expect: () => const [FoodItemsState(error: 'Failed to save')],
  );
}
