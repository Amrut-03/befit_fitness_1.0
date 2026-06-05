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
              ? _emptyState()
              : isCompletedToday
              ? _completedState()
              : _dataState(),
        ),
      ),
    );
  }

  Widget _completedState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF00E5FF).withOpacity(0.12),
          ),
          child: Icon(
            Icons.check_circle,
            color: const Color(0xFF00E5FF),
            size: 42.sp,
          ),
        ),

        SizedBox(height: 18.h),

        Text(
          "Meals Completed 🎉",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          "Awesome work! You completed all your meals for today.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
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
                const Color(0xFF00E5FF).withOpacity(0.25),
                const Color(0xFF00E5FF).withOpacity(0.08),
              ],
            ),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Text(
                "Daily Goal Achieved",
                style: TextStyle(
                  color: const Color(0xFF00E5FF),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 4.h),

              Text(
                "Your tracking will reset tomorrow",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
          ),
          child: Icon(
            Icons.restaurant_outlined,
            color: Colors.white.withOpacity(0.7),
            size: 24.sp,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          "No Active Plan",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "Start a diet plan to track your progress",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 14.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              "Explore Plans",
              style: TextStyle(
                color: const Color(0xFF00E5FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dataState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withOpacity(0.15),
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: const Color(0xFF00E5FF),
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Active Plan",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    planName ?? "Untitled Plan",
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
                color: const Color(0xFF00E5FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "ACTIVE",
                style: TextStyle(
                  color: const Color(0xFF00E5FF),
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
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF00E5FF)),
          ),
        ),
        SizedBox(height: 6.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${((progress ?? 0) * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11.sp,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _stat("Meals", "${consumedMeals ?? 0}/${totalMeals ?? 0}"),
            _stat("Calories", (totalCalories ?? 0).toStringAsFixed(0)),
          ],
        ),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF00E5FF),
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}
