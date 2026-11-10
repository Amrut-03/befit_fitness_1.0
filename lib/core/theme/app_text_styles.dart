import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared text styles. They read sizes through ScreenUtil, so they are
/// getters rather than constants.
abstract final class AppTextStyles {
  static TextStyle get headline => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get title => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get body =>
      TextStyle(color: AppColors.textPrimary, fontSize: 14.sp);

  static TextStyle get bodySecondary =>
      TextStyle(color: AppColors.textSecondary, fontSize: 14.sp);

  static TextStyle get caption =>
      TextStyle(color: AppColors.textMuted, fontSize: 12.sp);
}
