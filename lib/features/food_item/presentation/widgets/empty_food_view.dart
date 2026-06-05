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
          const Text("No Food Items", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
