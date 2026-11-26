import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyFoodView extends StatelessWidget {
  const EmptyFoodView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, color: Colors.white54, size: 60.sp),
          SizedBox(height: 12.h),
          Text(
            context.l10n.foodEmpty,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
