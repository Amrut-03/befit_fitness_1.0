import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_event.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One meal in a diet plan. Ticking it asks for confirmation, marks the meal
/// consumed for today and records streak activity.
class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.plan,
    required this.index,
    required this.meal,
  });

  final DietPlanEntity plan;
  final int index;
  final MealEntity meal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: meal.isConsumedToday
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.black,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IgnorePointer(
                ignoring: meal.isConsumedToday,
                child: Checkbox(
                  value: meal.isConsumedToday,
                  activeColor: AppColors.primary,
                  onChanged: (value) async {
                    if (value != true) return;

                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          backgroundColor: AppColors.surfaceElevated,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          title: Row(
                            children: [
                              Icon(
                                Icons.restaurant,
                                color: AppColors.primary,
                                size: 24.sp,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  "Confirm Meal",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          content: Text(
                            "Are you sure you consumed ${meal.name}?\n\nThis action cannot be undone today.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14.sp,
                              height: 1.5,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.white60),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: const Text(
                                "Confirm",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed != true || !context.mounted) return;

                    _toggleMeal(context, plan, index, true);
                  },
                ),
              ),
              Expanded(
                child: Text(
                  meal.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    decoration: meal.isConsumedToday
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              _nutrient("Calories", meal.calories),
              _nutrient("Protein", meal.protein),
              _nutrient("Carbs", meal.carbs),
              _nutrient("Fat", meal.fat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nutrient(String label, double value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white60, fontSize: 11.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _toggleMeal(
    BuildContext context,
    DietPlanEntity plan,
    int index,
    bool isConsumed,
  ) {
    final updatedMeals = List<MealEntity>.from(plan.meals);

    updatedMeals[index] = updatedMeals[index].copyWith(
      consumedAt: DateTime.now(),
    );

    context.read<DietBloc>().add(
      UpdateMealStatusEvent(planId: plan.id, meals: updatedMeals),
    );

    // Eating a planned meal counts as today's activity.
    context.read<StreakBloc>().add(UpdateStreakEvent());
  }
}
