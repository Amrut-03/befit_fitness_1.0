import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showDietDetailBottomSheet(BuildContext context, DietPlanEntity plan) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return _DietDetailBottomSheet(plan: plan);
    },
  );
}

class _DietDetailBottomSheet extends StatelessWidget {
  final DietPlanEntity plan;

  const _DietDetailBottomSheet({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.88.sh,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 60.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
          ),

          SizedBox(height: 24.h),

          Text(
            plan.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            "${plan.consumedMeals}/${plan.totalMeals} meals completed",
            style: TextStyle(color: Colors.white60, fontSize: 14.sp),
          ),

          SizedBox(height: 20.h),

          ClipRRect(
            borderRadius: BorderRadius.circular(100.r),
            child: LinearProgressIndicator(
              value: plan.progress,
              minHeight: 12.h,
              backgroundColor: Colors.white10,
              color: const Color(0xFF00E5FF),
            ),
          ),

          SizedBox(height: 28.h),

          Expanded(
            child: ListView.separated(
              itemCount: plan.meals.length,
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                final meal = plan.meals[index];

                return _MealCard(plan: plan, meal: meal);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final DietPlanEntity plan;
  final MealEntity meal;

  const _MealCard({required this.plan, required this.meal});

  @override
  Widget build(BuildContext context) {
    final isConsumed = meal.isConsumedToday;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: const Color(0xFF171717),
        border: Border.all(
          color: isConsumed ? const Color(0xFF00E5FF) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E5FF).withOpacity(0.12),
            ),
            child: Icon(
              Icons.restaurant,
              color: const Color(0xFF00E5FF),
              size: 24.sp,
            ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  "${meal.calories.toInt()} kcal • ${meal.protein.toInt()}g protein",
                  style: TextStyle(color: Colors.white60, fontSize: 12.sp),
                ),
              ],
            ),
          ),

          Checkbox(
            value: isConsumed,
            activeColor: const Color(0xFF00E5FF),
            onChanged: (_) {
              final updatedMeals = plan.meals.map((m) {
                if (m.id == meal.id) {
                  return m.copyWith(
                    consumedAt: isConsumed ? null : DateTime.now(),
                  );
                }

                return m;
              }).toList();

              context.read<DietBloc>().add(
                UpdateMealStatusEvent(planId: plan.id, meals: updatedMeals),
              );
            },
          ),
        ],
      ),
    );
  }
}
