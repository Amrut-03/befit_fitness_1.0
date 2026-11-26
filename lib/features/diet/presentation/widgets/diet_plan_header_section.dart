import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DietPlanHeaderSection extends StatelessWidget {
  final TextEditingController controller;

  final bool isExpanded;
  final VoidCallback onToggle;

  final double calories;
  final double carbs;
  final double protein;
  final double fat;

  final double caloriesGoal;
  final double carbsGoal;
  final double proteinGoal;
  final double fatGoal;

  const DietPlanHeaderSection({
    super.key,
    required this.controller,
    required this.isExpanded,
    required this.onToggle,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.caloriesGoal,
    required this.carbsGoal,
    required this.proteinGoal,
    required this.fatGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.dietPlanName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                decoration: InputDecoration(
                  hintText: context.l10n.dietEnterPlanName,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          // Expands or collapses the macro breakdown.
          onTap: onToggle,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.dietDailyMacros,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: isExpanded
                      ? Column(
                          children: [
                            SizedBox(height: 12.h),
                            _item(
                              context.l10n.statCalories,
                              calories,
                              caloriesGoal,
                              "kcal",
                              Colors.cyan,
                            ),
                            _item(
                              context.l10n.macroCarbs,
                              carbs,
                              carbsGoal,
                              "g",
                              Colors.green,
                            ),
                            _item(
                              context.l10n.macroProtein,
                              protein,
                              proteinGoal,
                              "g",
                              Colors.blue,
                            ),
                            _item(
                              context.l10n.macroFat,
                              fat,
                              fatGoal,
                              "g",
                              Colors.orange,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _item(
    String label,
    double consumed,
    double goal,
    String unit,
    Color color,
  ) {
    final percent = goal <= 0 ? 0.0 : (consumed / goal).clamp(0.0, 1.0);

    final isOver = consumed > goal;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(label, style: const TextStyle(color: Colors.white)),

              Text(
                "${consumed.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)} $unit",

                style: TextStyle(color: isOver ? Colors.red : Colors.white),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),

            child: LinearProgressIndicator(
              value: percent,

              minHeight: 6.h,

              backgroundColor: Colors.white12,

              valueColor: AlwaysStoppedAnimation(isOver ? Colors.red : color),
            ),
          ),
        ],
      ),
    );
  }
}
