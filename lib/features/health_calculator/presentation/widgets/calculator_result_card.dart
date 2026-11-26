import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/features/health_calculator/presentation/bloc/health_calculator_bloc.dart';

class CalculatorResultCard extends StatelessWidget {
  const CalculatorResultCard(this.state, {super.key});

  final HealthCalculatorLoaded state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Column(
        children: [
          Text(
            state.result.value.toString(),
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 40.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            state.result.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            state.result.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
