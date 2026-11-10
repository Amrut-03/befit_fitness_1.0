import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/di/injection_container.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/features/notifications/presentation/cubit/notification_settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reminder settings. Changes are saved and reminders rescheduled
/// immediately.
class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationSettingsCubit>(),
      child: const _NotificationSettingsView(),
    );
  }
}

class _NotificationSettingsView extends StatelessWidget {
  const _NotificationSettingsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<NotificationSettingsCubit>();
    final settings = cubit.state.settings;
    final workoutTime = TimeOfDay(
      hour: settings.workoutHour,
      minute: settings.workoutMinute,
    );

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppHeader(title: context.l10n.notifSettingsTitle),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            if (cubit.state.permissionDenied) ...[
              Text(
                context.l10n.notifDisabled,
                style: TextStyle(color: Colors.orangeAccent, fontSize: 13.sp),
              ),
              SizedBox(height: 16.h),
            ],

            _sectionTitle(context.l10n.notifReminders),

            SizedBox(height: 16.h),

            _notificationTile(
              title: context.l10n.notifWorkout,

              subtitle: context.l10n.notifWorkoutHint,

              value: settings.workoutReminder,

              onChanged: (v) =>
                  cubit.update(settings.copyWith(workoutReminder: v)),
            ),

            _notificationTile(
              title: context.l10n.notifWater,

              subtitle: context.l10n.notifWaterHint,

              value: settings.waterReminder,

              onChanged: (v) =>
                  cubit.update(settings.copyWith(waterReminder: v)),
            ),

            _notificationTile(
              title: context.l10n.notifMeal,

              subtitle: context.l10n.notifMealHint,

              value: settings.mealReminder,

              onChanged: (v) =>
                  cubit.update(settings.copyWith(mealReminder: v)),
            ),

            _notificationTile(
              title: context.l10n.notifStreak,

              subtitle: context.l10n.notifStreakHint,

              value: settings.streakReminder,

              onChanged: (v) =>
                  cubit.update(settings.copyWith(streakReminder: v)),
            ),

            SizedBox(height: 30.h),

            _sectionTitle(context.l10n.notifReminderTime),

            SizedBox(height: 16.h),

            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,

                  initialTime: workoutTime,
                );

                if (picked != null) {
                  await cubit.update(
                    settings.copyWith(
                      workoutHour: picked.hour,
                      workoutMinute: picked.minute,
                    ),
                  );
                }
              },

              child: Container(
                padding: EdgeInsets.all(18.w),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),

                  borderRadius: BorderRadius.circular(20.r),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: AppColors.primary),

                    SizedBox(width: 14.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            context.l10n.notifWorkoutTime,

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: 14.sp,

                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 4.h),

                          Text(
                            workoutTime.format(context),

                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),

                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios,

                      color: Colors.white.withValues(alpha: 0.4),

                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,

      style: TextStyle(
        color: Colors.white,

        fontSize: 18.sp,

        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _notificationTile({
    required String title,

    required String subtitle,

    required bool value,

    required Function(bool) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),

      padding: EdgeInsets.all(18.w),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),

        borderRadius: BorderRadius.circular(20.r),
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 14.sp,

                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  subtitle,

                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),

                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: value,

            activeThumbColor: AppColors.primary,

            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
