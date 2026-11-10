import 'dart:io' show Platform;

import 'package:fitness_app/core/health/health_platform_service.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/health_bloc.dart';
import '../bloc/health_event.dart';
import '../bloc/health_state.dart';

/// Invites the user to connect Health Connect (Android) or Apple Health (iOS).
/// Hidden once connected, or when the device has no health store.
class HealthPlatformPrompt extends StatelessWidget {
  const HealthPlatformPrompt({super.key, this.isIOS});

  /// Overrides the platform check (for tests).
  final bool? isIOS;

  @override
  Widget build(BuildContext context) {
    final status = context.select<HealthBloc, HealthPlatformStatus?>(
      (bloc) => switch (bloc.state) {
        HealthLoaded(:final platformStatus) => platformStatus,
        _ => null,
      },
    );

    if (status != HealthPlatformStatus.notConnected &&
        status != HealthPlatformStatus.needsInstall) {
      return const SizedBox.shrink();
    }

    final ios = isIOS ?? Platform.isIOS;
    final storeName = ios ? 'Apple Health' : 'Health Connect';
    final needsInstall = status == HealthPlatformStatus.needsInstall;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.favorite_rounded,
            color: AppColors.accentPink,
            size: 28.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connect $storeName',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  needsInstall
                      ? 'Install or update Health Connect to sync steps, '
                            'calories, sleep and heart rate.'
                      : 'Sync steps, calories, sleep, heart rate and weight '
                            'from your watch and other apps.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          TextButton(
            onPressed: () => context.read<HealthBloc>().add(
              ConnectHealthPlatformRequested(),
            ),
            child: Text(
              needsInstall ? 'Install' : 'Connect',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
