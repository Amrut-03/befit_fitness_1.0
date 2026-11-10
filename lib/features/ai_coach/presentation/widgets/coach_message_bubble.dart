import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/coach_message.dart';

class CoachMessageBubble extends StatelessWidget {
  const CoachMessageBubble({
    super.key,
    required this.message,
    this.streaming = false,
  });

  final CoachMessage message;

  /// The answer is still being generated.
  final bool streaming;

  static String? sourceLabel(CoachSource? s) => switch (s) {
    CoachSource.onDevice => 'On-device',
    CoachSource.cloud => 'Cloud',
    CoachSource.rule || null => null,
  };

  @override
  Widget build(BuildContext context) {
    final user = message.isUser;
    final label = sourceLabel(message.source);
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 0.82.sw),
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: user
                ? AppColors.primary.withValues(alpha: 0.16)
                : AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(user ? 16.r : 4.r),
              bottomRight: Radius.circular(user ? 4.r : 16.r),
            ),
            border: message.failed
                ? Border.all(color: AppColors.error.withValues(alpha: 0.4))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.text.isEmpty && streaming)
                Text(
                  'Thinking…',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14.sp,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                SelectableText(
                  message.text,
                  style: TextStyle(
                    color: message.failed
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontSize: 14.sp,
                    height: 1.35,
                  ),
                ),
              if (!user && label != null && !streaming) ...[
                SizedBox(height: 6.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      message.source == CoachSource.onDevice
                          ? Icons.phone_android
                          : Icons.cloud_outlined,
                      size: 12.sp,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
