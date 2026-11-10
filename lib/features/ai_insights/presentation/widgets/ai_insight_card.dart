import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/ai_insights/domain/entities/ai_insights_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AIInsightCard extends StatelessWidget {
  final AIInsightEntity insight;

  const AIInsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),

      padding: EdgeInsets.all(18.w),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),

        gradient: LinearGradient(
          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [
            Colors.white.withValues(alpha: 0.06),

            Colors.white.withValues(alpha: 0.03),
          ],
        ),

        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),

      child: Row(
        children: [
          Text(insight.emoji, style: TextStyle(fontSize: 26.sp)),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  insight.title,

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 15.sp,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  insight.message,

                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),

                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
