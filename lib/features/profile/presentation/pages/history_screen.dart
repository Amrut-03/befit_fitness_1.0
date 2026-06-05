import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_header.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B0B0B),

      appBar: const AppHeader(title: "History"),

      body: Padding(
        padding: EdgeInsets.all(16.w),

        child: Column(
          children: [
            _HistoryCard(
              icon: Icons.restaurant_menu,
              title: "Diet History",
              subtitle: "View completed diet plans",
              color: const Color(0xFF00E5FF),
              onTap: () {
                context.push('/diet-history');
              },
            ),

            SizedBox(height: 16.h),

            _HistoryCard(
              icon: Icons.fitness_center,
              title: "Workout History",
              subtitle: "View completed workouts",
              color: const Color(0xFFFF6B35),
              onTap: () {
                context.push('/workout-history');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final IconData icon;

  final String title;

  final String subtitle;

  final Color color;

  final VoidCallback onTap;

  const _HistoryCard({
    required this.icon,

    required this.title,

    required this.subtitle,

    required this.color,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(20.r),

      child: Container(
        width: double.infinity,

        padding: EdgeInsets.all(18.w),

        decoration: BoxDecoration(
          color: Colors.black,

          borderRadius: BorderRadius.circular(20.r),

          border: Border.all(color: Colors.white10),
        ),

        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14.w),

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: color.withOpacity(0.15),
              ),

              child: Icon(icon, color: color, size: 26.sp),
            ),

            SizedBox(width: 14.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: 18.sp,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    subtitle,

                    style: TextStyle(color: Colors.white60, fontSize: 13.sp),
                  ),
                ],
              ),
            ),

            Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 18.sp),
          ],
        ),
      ),
    );
  }
}
