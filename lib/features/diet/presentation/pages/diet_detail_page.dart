import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_event.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_state.dart';
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
        color: const Color(0xff0B0B0B),
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
                            (meal) => _buildMealCard(
                              context,
                              currentPlan,
                              currentPlan.meals.indexOf(meal),
                              meal,
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
                            (meal) => _buildMealCard(
                              context,
                              currentPlan,
                              currentPlan.meals.indexOf(meal),
                              meal,
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
          color: color.withOpacity(0.12),
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

  Widget _buildMealCard(
    BuildContext context,
    DietPlanEntity plan,
    int index,
    MealEntity meal,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: meal.isConsumedToday
            ? Colors.green.withOpacity(0.15)
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
                  activeColor: const Color(0xFF00E5FF),

                  onChanged: (value) async {
                    if (value != true) return;

                    final confirmed = await showDialog<bool>(
                      context: context,

                      builder: (_) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFF171717),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),

                          title: Row(
                            children: [
                              Icon(
                                Icons.restaurant,
                                color: const Color(0xFF00E5FF),
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

                              child: Text(
                                "Cancel",
                                style: TextStyle(color: Colors.white60),
                              ),
                            ),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),

                              onPressed: () {
                                Navigator.pop(context, true);
                              },

                              child: Text(
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

                    if (confirmed != true) return;

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

          SizedBox(height: 12.h),

          // Row(
          //   mainAxisAlignment:
          //       MainAxisAlignment.spaceBetween,
          //   children: [

          //     Text(
          //       meal.alarmTime != null
          //           ? _formatTime(
          //               meal.alarmTime!,
          //             )
          //           : "No Reminder Set",

          //       style: TextStyle(
          //         color:
          //             meal.alarmTime != null
          //                 ? Colors.orange
          //                 : Colors.white54,

          //         fontSize: 12.sp,
          //         fontWeight:
          //             FontWeight.w600,
          //       ),
          //     ),

          // PopupMenuButton<String>(

          //   onSelected:
          //       (value) async {

          //     if (value == "clear") {

          //       final updatedMeals =
          //           List<MealEntity>.from(
          //         plan.meals,
          //       );

          //       updatedMeals[index] =
          //           updatedMeals[index]
          //               .copyWith(
          //         alarmTime: null,
          //       );

          //       context
          //           .read<DietBloc>()
          //           .add(

          //         UpdateMealStatusEvent(
          //           planId: plan.id,
          //           meals: updatedMeals,
          //         ),
          //       );

          //       return;
          //     }

          //     final picked =
          //         await showTimePicker(

          //       context: context,

          //       initialTime:
          //           TimeOfDay.now(),
          //     );

          //     if (picked == null) return;

          //     final now =
          //         DateTime.now();

          //     final alarmDateTime =
          //         DateTime(
          //       now.year,
          //       now.month,
          //       now.day,
          //       picked.hour,
          //       picked.minute,
          //     );

          //     final updatedMeals =
          //         List<MealEntity>.from(
          //       plan.meals,
          //     );

          //     updatedMeals[index] =
          //         updatedMeals[index]
          //             .copyWith(
          //       alarmTime:
          //           alarmDateTime,
          //     );

          //     context
          //         .read<DietBloc>()
          //         .add(

          //       UpdateMealStatusEvent(
          //         planId: plan.id,
          //         meals: updatedMeals,
          //       ),
          //     );
          //   },

          //   color: Colors.black,

          //   itemBuilder: (_) => [

          //     const PopupMenuItem(
          //       value: "set",

          //       child: Text(
          //         "Set Alarm",
          //         style: TextStyle(
          //           color: Colors.white,
          //         ),
          //       ),
          //     ),

          //     const PopupMenuItem(
          //       value: "clear",

          //       child: Text(
          //         "Remove Alarm",
          //         style: TextStyle(
          //           color: Colors.red,
          //         ),
          //       ),
          //     ),
          //   ],

          //   child: Container(

          //     padding:
          //         EdgeInsets.symmetric(
          //       horizontal: 12.w,
          //       vertical: 6.h,
          //     ),

          //     decoration: BoxDecoration(
          //       color:
          //           Colors.orange
          //               .withOpacity(
          //         0.12,
          //       ),

          //       borderRadius:
          //           BorderRadius.circular(
          //         10.r,
          //       ),
          //     ),

          //     child: Row(
          //       children: [

          //         Icon(
          //           Icons.alarm,
          //           color: Colors.orange,
          //           size: 16.sp,
          //         ),

          //         SizedBox(width: 6.w),

          //         Text(
          //           "Reminder",
          //           style: TextStyle(
          //             color:
          //                 Colors.orange,
          //             fontSize: 12.sp,
          //             fontWeight:
          //                 FontWeight.w600,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // ],
          // ),
          SizedBox(height: 12.h),

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
  }
}
