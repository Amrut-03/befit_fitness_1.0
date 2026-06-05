import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/education_info.dart';

class EducationBottomSheet {
  static void show(BuildContext context, EducationInfo info) {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: const Color(0xFF111111),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),

      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(24.w),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Center(
                child: Container(
                  width: 40.w,

                  height: 4.h,

                  decoration: BoxDecoration(
                    color: Colors.white24,

                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Row(
                children: [
                  Text(info.emoji, style: TextStyle(fontSize: 30.sp)),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: Text(
                      info.title,

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 20.sp,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              Text(
                info.description,

                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),

              SizedBox(height: 20.h),

              Text(
                "Why it matters",

                style: TextStyle(
                  color: Colors.white,

                  fontWeight: FontWeight.bold,

                  fontSize: 16.sp,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                info.whyImportant,

                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),

              SizedBox(height: 20.h),

              Text(
                "Tips",

                style: TextStyle(
                  color: Colors.white,

                  fontWeight: FontWeight.bold,

                  fontSize: 16.sp,
                ),
              ),

              SizedBox(height: 10.h),

              ...info.tips.map(
                (tip) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text("• ", style: TextStyle(color: Colors.white)),

                      Expanded(
                        child: Text(
                          tip,

                          style: TextStyle(
                            color: Colors.white70,

                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}
