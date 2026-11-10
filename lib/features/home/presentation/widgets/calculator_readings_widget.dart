import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/features/home/presentation/widgets/fitness_reading_item.dart';

class CalculatorReadingsWidget extends StatelessWidget {
  final VoidCallback onClick;
  final int steps;
  final double calories;
  final int? moveMin;
  final String? previousSteps;
  final String? previousCalories;
  final String? previousMoveMin;

  const CalculatorReadingsWidget({
    super.key,
    required this.onClick,
    required this.steps,
    required this.calories,
    this.moveMin,
    this.previousSteps,
    this.previousCalories,
    this.previousMoveMin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FitnessReadingItem(
            onTap: onClick,
            lottieAsset: 'assets/lotties/steps.json',
            value: _formatSteps(steps),
            label: 'Steps',
            previousValue: previousSteps,
          ),
          Divider(
            indent: 8.w,
            endIndent: 8.w,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          FitnessReadingItem(
            onTap: onClick,
            lottieAsset: 'assets/lotties/flame.json',
            value: calories.toStringAsFixed(0),
            label: 'Calories',
            bottomSpacing: 2.h,
            previousValue: previousCalories,
          ),
          Divider(
            indent: 8.w,
            endIndent: 8.w,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          FitnessReadingItem(
            onTap: onClick,
            lottieAsset: 'assets/lotties/heart.json',
            value: moveMin != null ? moveMin!.toString() : '0',
            label: 'Move Min',
            lottieHeight: 25.h,
            lottieWidth: 25.w,
            topSpacing: 4.h,
            bottomSpacing: 3.h,
            previousValue: previousMoveMin,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000000) {
      return '${(steps / 1000000).toStringAsFixed(1)}M';
    } else if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}K';
    } else {
      return steps.toString();
    }
  }
}
