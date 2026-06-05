import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';
import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_bloc.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_event.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showAddFoodBottomSheet(
  BuildContext context,
  Function(List<MealEntity>) onSelected,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AddFoodSheet(onSelected: onSelected),
  );
}

class _AddFoodSheet extends StatefulWidget {
  final Function(List<MealEntity>) onSelected;

  const _AddFoodSheet({required this.onSelected});

  @override
  State<_AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<_AddFoodSheet> {
  String search = "";
  Set<String> selectedIds = {};

  @override
  void initState() {
    super.initState();

    context.read<FoodItemsBloc>().add(LoadFoodItems());
  }

  void toggle(MealEntity meal) {
    setState(() {
      if (selectedIds.contains(meal.id)) {
        selectedIds.remove(meal.id);
      } else {
        selectedIds.add(meal.id);
      }
    });
  }

  void submit(List<FoodItemEntity> foods) {
    final selectedMeals = foods
        .where((food) => selectedIds.contains(food.id))
        .map((food) {
          return MealEntity(
            id: food.id,

            name: food.name,

            calories: food.calories ?? 0,

            protein: food.protein ?? 0,

            carbs: food.carbs ?? 0,

            fat: food.fat ?? 0,

            consumedAt: null,
          );
        })
        .toList();

    Navigator.pop(context);

    widget.onSelected(selectedMeals);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Food items",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (val) => setState(() => search = val),
            decoration: InputDecoration(
              hintText: "Search food...",
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white10,
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: BlocBuilder<FoodItemsBloc, FoodItemsState>(
              builder: (context, state) {
                if (state.isLoading && state.items.isEmpty) {
                  return const AppLoader();
                }

                final foods = state.items.where((food) {
                  if (search.isEmpty) {
                    return true;
                  }

                  return food.name.toLowerCase().contains(search.toLowerCase());
                }).toList();

                if (foods.isEmpty) {
                  return const Center(
                    child: Text(
                      'No food items found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: foods.length,

                  itemBuilder: (_, index) {
                    final item = foods[index];

                    final selected = selectedIds.contains(item.id);

                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),

                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.teal.withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(
                          color: selected ? Colors.teal : Colors.white12,
                        ),
                      ),

                      child: ListTile(
                        title: Text(
                          item.name,

                          style: const TextStyle(color: Colors.white),
                        ),

                        subtitle: Text(
                          "${item.calories ?? 0} kcal",

                          style: const TextStyle(color: Colors.white70),
                        ),

                        trailing: Checkbox(
                          value: selected,

                          onChanged: (_) {
                            setState(() {
                              if (selected) {
                                selectedIds.remove(item.id);
                              } else {
                                selectedIds.add(item.id);
                              }
                            });
                          },
                        ),

                        onTap: () {
                          setState(() {
                            if (selected) {
                              selectedIds.remove(item.id);
                            } else {
                              selectedIds.add(item.id);
                            }
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (selectedIds.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final state = context.read<FoodItemsBloc>().state;

                  submit(state.items);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  "Add ${selectedIds.length} Food",
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
