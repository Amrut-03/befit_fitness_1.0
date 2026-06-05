import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'food_entry_card.dart';

class FoodEntryList extends StatelessWidget {
  final List<MealEntity> meals;
  final List<String> mealOptions;

  final Function(List<MealEntity>) onReorder;
  final Function(int index) onDelete;
  final Function(int index, String value)? onMealNameChanged;
  final Function(int index, String value)? onAlarmAction;
  final Function(int index)? onQuantityTap;

  const FoodEntryList({
    super.key,
    required this.meals,
    required this.mealOptions,
    required this.onReorder,
    required this.onDelete,
    this.onMealNameChanged,
    this.onAlarmAction,
    this.onQuantityTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayMeals = meals;

    if (meals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.restaurant_menu, color: Colors.white24, size: 70.sp),

            SizedBox(height: 16.h),

            Text(
              'No food added yet',

              style: TextStyle(
                color: Colors.white70,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'Tap "Add Food" to build your diet plan',

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.white38, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }
    return AnimatedReorderableListView(
      shrinkWrap: false,
      physics: const ClampingScrollPhysics(),
      items: displayMeals,
      isSameItem: (a, b) => a.id == b.id,
      onReorder: (oldIndex, newIndex) {
        final updated = List<MealEntity>.from(meals);
        final item = updated.removeAt(oldIndex);
        updated.insert(newIndex, item);
        onReorder(updated);
      },

      padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 100.h),

      itemBuilder: (context, index) {
        final entry = displayMeals[index];

        return FoodEntryCard(
          key: ValueKey(entry.id),
          entry: entry,
          index: index,
          mealOptions: mealOptions,
          onDelete: () => onDelete(index),
          onMealNameChanged: (value) {
            if (onMealNameChanged != null) {
              onMealNameChanged!(index, value);
            }
          },
          onQuantityTap: () {
            if (onQuantityTap != null) {
              onQuantityTap!(index);
            }
          },
        );
      },
    );
  }
}
