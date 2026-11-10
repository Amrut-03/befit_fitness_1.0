import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/routes/routes.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../calculator_labels.dart';

class HealthCalculatorListPage extends StatelessWidget {
  const HealthCalculatorListPage({super.key});

  static const calculators = [
    {'type': 'BMI', 'icon': Icons.monitor_weight, 'color': AppColors.primary},

    {
      'type': 'Water Intake',

      'icon': Icons.water_drop,

      'color': Color(0xFF4D96FF),
    },

    {'type': 'Protein', 'icon': Icons.egg_alt, 'color': AppColors.accentPink},

    {
      'type': 'Calories',

      'icon': Icons.local_fire_department,

      'color': AppColors.warning,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppHeader(title: context.l10n.calcTitle),

      body: ListView.separated(
        padding: EdgeInsets.all(20.w),

        itemCount: calculators.length,

        separatorBuilder: (_, _) => SizedBox(height: 16.h),

        itemBuilder: (context, index) {
          final item = calculators[index];

          return InkWell(
            borderRadius: BorderRadius.circular(22.r),

            onTap: () {
              context.push(Routes.healthCalculator(item['type']! as String));
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

                      color: (item['color'] as Color).withValues(alpha: 0.15),
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
                          calculatorTitle(
                            context.l10n,
                            item['type']! as String,
                          ),

                          style: TextStyle(
                            color: Colors.white,

                            fontSize: 16.sp,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          calculatorSubtitle(
                            context.l10n,
                            item['type']! as String,
                          ),

                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),

                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios,

                    color: Colors.white.withValues(alpha: 0.5),

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
