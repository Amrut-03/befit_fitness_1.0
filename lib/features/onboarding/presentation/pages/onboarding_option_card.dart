import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingOptionCard extends StatelessWidget {
  final String title;

  final String emoji;

  final bool isSelected;

  final VoidCallback onTap;

  const OnboardingOptionCard({
    super.key,

    required this.title,

    required this.emoji,

    required this.isSelected,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),

      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),

        onTap: onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),

          padding: EdgeInsets.all(20.w),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),

            gradient: LinearGradient(
              colors: isSelected
                  ? [const Color(0xFF00E5FF), const Color(0xFF00B8D4)]
                  : [
                      Colors.white.withOpacity(0.05),

                      Colors.white.withOpacity(0.02),
                    ],
            ),

            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00E5FF)
                  : Colors.white.withOpacity(0.08),
            ),

            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.35),

                      blurRadius: 24,

                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),

          child: Row(
            children: [
              /// EMOJI
              Text(emoji, style: TextStyle(fontSize: 32.sp)),

              SizedBox(width: 18.w),

              /// TITLE
              Expanded(
                child: Text(
                  title,

                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,

                    fontSize: 18.sp,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// CHECK ICON
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),

                height: 28.h,

                width: 28.w,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: isSelected ? Colors.black : Colors.transparent,

                  border: Border.all(
                    color: isSelected
                        ? Colors.black
                        : Colors.white.withOpacity(0.3),
                  ),
                ),

                child: isSelected
                    ? Icon(
                        Icons.check,

                        color: const Color(0xFF00E5FF),

                        size: 18.sp,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
