import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HomeHeader extends StatelessWidget {
  final String userName;

  const HomeHeader({super.key, required this.userName});

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            context.push('/profile');
          },
          child: CircleAvatar(
            radius: 24.r,
            backgroundColor: Colors.white12,
            child: Icon(Icons.person, color: Colors.white, size: 24.sp),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getGreeting(),
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                userName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.notifications_none, size: 28.sp),
          color: Colors.white,
          onPressed: () {
            context.push('/notification-page');
          },
        ),
      ],
    );
  }
}
