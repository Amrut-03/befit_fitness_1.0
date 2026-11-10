import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/ai/on_device_llm.dart';
import 'package:fitness_app/core/config/app_config.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/on_device_model_cubit.dart';

/// Offers the on-device model download and shows its progress. Hidden when
/// the model is ready or on-device AI isn't configured.
class OnDeviceModelCard extends StatelessWidget {
  const OnDeviceModelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnDeviceModelCubit, OnDeviceModelState>(
      builder: (context, state) {
        final cubit = context.read<OnDeviceModelCubit>();
        if (state.downloading) {
          return _Frame(
            icon: Icons.downloading_rounded,
            title: context.l10n.coachDownloading(state.progress),
            body: Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: state.progress / 100,
                  minHeight: 6.h,
                  color: AppColors.primary,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
            action: TextButton(
              onPressed: cubit.cancel,
              child: Text(context.l10n.commonCancel),
            ),
          );
        }
        return switch (state.status) {
          OnDeviceModelStatus.notDownloaded => _Frame(
            icon: Icons.offline_bolt_outlined,
            title: context.l10n.coachRunOffline,
            body: Text(
              state.error ??
                  context.l10n.coachDownloadHint(AppConfig.onDeviceModelSize),
              style: TextStyle(
                color: state.error != null
                    ? AppColors.error
                    : AppColors.textSecondary,
                fontSize: 12.sp,
              ),
            ),
            action: TextButton(
              onPressed: cubit.download,
              child: Text(
                state.error != null
                    ? context.l10n.commonRetry
                    : context.l10n.coachDownload,
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ),
          OnDeviceModelStatus.unsupported => _Frame(
            icon: Icons.cloud_outlined,
            title: context.l10n.coachUsingCloud,
            body: Text(
              context.l10n.coachLowMemory,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
            ),
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final Widget body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 8.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                body,
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
