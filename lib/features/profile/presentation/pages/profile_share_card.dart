import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileShareCard extends StatelessWidget {
  final String name;

  final String goal;

  final double weight;

  final int streak;

  final int calories;

  final int steps;

  final double bmi;

  const ProfileShareCard({
    super.key,

    required this.name,

    required this.goal,

    required this.weight,

    required this.streak,

    required this.calories,

    required this.steps,

    required this.bmi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(24.w),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34.r),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [Color(0xFF0D0D0D), Color(0xFF111111), Color(0xFF1A1A1A)],
        ),

        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.15)),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.08),

            blurRadius: 30,

            spreadRadius: 1,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// TOP HEADER
          Row(
            children: [
              Container(
                width: 72.w,

                height: 72.w,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: const Color(0xFF00E5FF),
                ),

                child: Center(
                  child: Text(
                    name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : "A",

                    style: TextStyle(
                      color: Colors.black,

                      fontSize: 34.sp,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 18.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      name,

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 24.sp,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      goal,

                      style: TextStyle(
                        color: const Color(0xFF00E5FF),

                        fontSize: 14.sp,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 34.h),

          /// STATS GRID
          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: "Weight",

                  value: "${weight.round()} kg",

                  icon: Icons.monitor_weight,

                  color: const Color(0xFF00E5FF),
                ),
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: _statCard(
                  title: "BMI",

                  value: bmi.toStringAsFixed(1),

                  icon: Icons.favorite,

                  color: const Color(0xFFFF006E),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: "Calories",

                  value: "$calories kcal",

                  icon: Icons.local_fire_department,

                  color: const Color(0xFFFFB703),
                ),
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: _statCard(
                  title: "Steps",

                  value: "$steps",

                  icon: Icons.directions_walk,

                  color: const Color(0xFF00E5FF),
                ),
              ),
            ],
          ),

          SizedBox(height: 30.h),

          /// STREAK
          Container(
            width: double.infinity,

            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),

              borderRadius: BorderRadius.circular(24.r),
            ),

            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(14.w),

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: Colors.orange.withOpacity(0.15),
                  ),

                  child: Icon(
                    Icons.local_fire_department,

                    color: Colors.orange,

                    size: 28.sp,
                  ),
                ),

                SizedBox(width: 16.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "$streak Day Streak",

                        style: TextStyle(
                          color: Colors.white,

                          fontSize: 20.sp,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        "Consistency creates results",

                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),

                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 34.h),

          /// QUOTE
          Center(
            child: Column(
              children: [
                Text(
                  '"Discipline beats motivation."',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 18.sp,

                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 10.h),

                Text(
                  "Generated with BeFit",

                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),

                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,

    required String value,

    required IconData icon,

    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),

        borderRadius: BorderRadius.circular(24.r),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            padding: EdgeInsets.all(10.w),

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: color.withOpacity(0.15),
            ),

            child: Icon(icon, color: color, size: 20.sp),
          ),

          SizedBox(height: 18.h),

          Text(
            value,

            style: TextStyle(
              color: Colors.white,

              fontSize: 18.sp,

              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            title,

            style: TextStyle(
              color: Colors.white.withOpacity(0.5),

              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
