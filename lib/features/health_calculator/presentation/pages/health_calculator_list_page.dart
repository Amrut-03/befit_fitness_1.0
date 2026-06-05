import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

class HealthCalculatorListPage extends StatelessWidget {
  const HealthCalculatorListPage({super.key});

  static const calculators = [
    {
      'title': 'BMI Calculator',

      'subtitle': 'Check body mass index',

      'type': 'BMI',

      'icon': Icons.monitor_weight,

      'color': const Color(0xFF00E5FF),
    },

    {
      'title': 'Water Intake',

      'subtitle': 'Daily hydration goal',

      'type': 'Water Intake',

      'icon': Icons.water_drop,

      'color': Color(0xFF4D96FF),
    },

    {
      'title': 'Protein Calculator',

      'subtitle': 'Daily protein target',

      'type': 'Protein',

      'icon': Icons.egg_alt,

      'color': Color(0xFFFF006E),
    },

    {
      'title': 'Calories Calculator',

      'subtitle': 'Maintenance calories',

      'type': 'Calories',

      'icon': Icons.local_fire_department,

      'color': Color(0xFFFFB703),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),

      appBar: AppHeader(title: "Health Calculators"),

      body: ListView.separated(
        padding: EdgeInsets.all(20.w),

        itemCount: calculators.length,

        separatorBuilder: (_, __) => SizedBox(height: 16.h),

        itemBuilder: (context, index) {
          final item = calculators[index];

          return InkWell(
            borderRadius: BorderRadius.circular(22.r),

            onTap: () {
              context.push('/health-calculator', extra: item['type']);
            },

            child: Container(
              padding: EdgeInsets.all(18.w),

              decoration: BoxDecoration(
                color: Colors.black,

                borderRadius: BorderRadius.circular(22.r),
              ),

              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.w),

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: (item['color'] as Color).withOpacity(0.15),
                    ),

                    child: Icon(
                      item['icon'] as IconData,

                      color: item['color'] as Color,

                      size: 24.sp,
                    ),
                  ),

                  SizedBox(width: 16.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          item['title'] as String,

                          style: TextStyle(
                            color: Colors.white,

                            fontSize: 16.sp,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          item['subtitle'] as String,

                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),

                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios,

                    color: Colors.white.withOpacity(0.5),

                    size: 16.sp,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
