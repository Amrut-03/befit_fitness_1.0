import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthButton extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isPrimary;
  const AuthButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isLoading,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24.r),
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 62.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF00B8D4)],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
                ),
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.35),
                    blurRadius: 20.r,
                    spreadRadius: 1.r,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 14.w),
            isLoading
                ? AppLoader()
                : Text(
                    title,
                    style: TextStyle(
                      color: isPrimary ? Colors.black : Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
