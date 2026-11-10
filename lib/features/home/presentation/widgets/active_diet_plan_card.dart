import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActiveDietPlanCard extends StatelessWidget {
  final String? planName;
  final int? totalMeals;
  final int? consumedMeals;
  final double? totalCalories;
  final double? progress;
  final VoidCallback onTap;
  final bool isCompletedToday;

  const ActiveDietPlanCard({
    super.key,
    this.planName,
    this.totalMeals,
    this.consumedMeals,
    this.isCompletedToday = false,
    this.totalCalories,
    this.progress,
    required this.onTap,
  });

  bool get isEmpty => planName == null || planName!.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: isEmpty
              ? _emptyState(context)
              : isCompletedToday
              ? _completedState(context)
              : _dataState(context),
        ),
      ),
    );
  }

  Widget _completedState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
          child: Icon(
            Icons.check_circle,
            color: AppColors.primary,
            size: 42.sp,
          ),
        ),

        SizedBox(height: 18.h),

        Text(
          context.l10n.dietCardAllDone,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          context.l10n.dietCardAllDoneBody,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13.sp,
            height: 1.5,
          ),
        ),

        SizedBox(height: 18.h),

        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.25),
                AppColors.primary.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Text(
                context.l10n.dietCardGoalAchieved,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 4.h),

              Text(
                context.l10n.dietCardResets,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Icon(
            Icons.restaurant_outlined,
            color: Colors.white.withValues(alpha: 0.7),
            size: 24.sp,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          context.l10n.dietCardNoPlan,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          context.l10n.dietCardNoPlanBody,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 14.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              context.l10n.dietCardExplore,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dataState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: AppColors.primary,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.dietCardActivePlan,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    planName ?? context.l10n.dietCardUntitled,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                context.l10n.dietCardActiveBadge,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: LinearProgressIndicator(
            value: progress ?? 0,
            minHeight: 8.h,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        SizedBox(height: 6.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${((progress ?? 0) * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11.sp,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _stat(
              context.l10n.dietCardMeals,
              "${consumedMeals ?? 0}/${totalMeals ?? 0}",
            ),
            _stat(
              context.l10n.statCalories,
              (totalCalories ?? 0).toStringAsFixed(0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}
