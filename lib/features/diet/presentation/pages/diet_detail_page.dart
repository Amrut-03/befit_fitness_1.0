import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_state.dart';
import 'package:fitness_app/features/diet/presentation/widgets/meal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: BlocBuilder<DietBloc, DietState>(
        builder: (context, state) {
          final currentPlan = state.plans.firstWhere(
            (p) => p.id == plan.id,
            orElse: () => plan,
          );

          final pendingMeals = currentPlan.meals
              .where((e) => !e.isConsumedToday)
              .toList();

          final completedMeals = currentPlan.meals
              .where((e) => e.isConsumedToday)
              .toList();

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 12.h),

                  Container(
                    width: 50.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentPlan.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        _buildHeader(currentPlan),
                        SizedBox(height: 16.h),
                        _buildMacros(currentPlan),
                        SizedBox(height: 16.h),
                        if (pendingMeals.isNotEmpty) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Pending Meals",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          ...pendingMeals.map(
                            (meal) => MealCard(
                              plan: currentPlan,
                              index: currentPlan.meals.indexOf(meal),
                              meal: meal,
                            ),
                          ),
                        ],
                        if (completedMeals.isNotEmpty) ...[
                          SizedBox(height: 20.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Completed Meals",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          ...completedMeals.map(
                            (meal) => MealCard(
                              plan: currentPlan,
                              index: currentPlan.meals.indexOf(meal),
                              meal: meal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(DietPlanEntity plan) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${plan.totalMeals} meals",
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: plan.progress,
            color: Colors.green,
            backgroundColor: Colors.grey[800],
          ),
        ],
      ),
    );
  }

  Widget _buildMacros(DietPlanEntity plan) {
    final protein = plan.meals.fold(0.0, (sum, m) => sum + m.protein);

    final carbs = plan.meals.fold(0.0, (sum, m) => sum + m.carbs);

    final fat = plan.meals.fold(0.0, (sum, m) => sum + m.fat);

    final calories = plan.meals.fold(0.0, (sum, m) => sum + m.calories);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Nutrition",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _macro("Calories", calories, "kcal", Colors.orange),
              _macro("Protein", protein, "g", Colors.blue),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _macro("Carbs", carbs, "g", Colors.green),
              _macro("Fat", fat, "g", Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macro(String title, double value, String unit, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.white70, fontSize: 12.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              "${value.toStringAsFixed(1)} $unit",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
