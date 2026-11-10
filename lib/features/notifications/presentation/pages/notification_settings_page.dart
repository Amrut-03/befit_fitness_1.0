import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationSettingPage extends StatefulWidget {
  const NotificationSettingPage({super.key});

  @override
  State<NotificationSettingPage> createState() =>
      _NotificationSettingPageState();
}

class _NotificationSettingPageState extends State<NotificationSettingPage> {
  bool workoutReminder = true;

  bool waterReminder = true;

  bool mealReminder = false;

  bool streakReminder = true;

  TimeOfDay workoutTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),

      appBar: AppHeader(title: "Notification Settings"),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _sectionTitle("Reminders"),

            SizedBox(height: 16.h),

            _notificationTile(
              title: "Workout Reminder",

              subtitle: "Daily workout motivation",

              value: workoutReminder,

              onChanged: (v) {
                setState(() {
                  workoutReminder = v;
                });
              },
            ),

            _notificationTile(
              title: "Water Reminder",

              subtitle: "Stay hydrated daily",

              value: waterReminder,

              onChanged: (v) {
                setState(() {
                  waterReminder = v;
                });
              },
            ),

            _notificationTile(
              title: "Meal Reminder",

              subtitle: "Track your daily meals",

              value: mealReminder,

              onChanged: (v) {
                setState(() {
                  mealReminder = v;
                });
              },
            ),

            _notificationTile(
              title: "Streak Reminder",

              subtitle: "Keep your streak alive",

              value: streakReminder,

              onChanged: (v) {
                setState(() {
                  streakReminder = v;
                });
              },
            ),

            SizedBox(height: 30.h),

            _sectionTitle("Reminder Time"),

            SizedBox(height: 16.h),

            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,

                  initialTime: workoutTime,
                );

                if (picked != null) {
                  setState(() {
                    workoutTime = picked;
                  });
                }
              },

              child: Container(
                padding: EdgeInsets.all(18.w),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),

                  borderRadius: BorderRadius.circular(20.r),
                ),

                child: Row(
                  children: [
                    Icon(Icons.access_time, color: const Color(0xFF00E5FF)),

                    SizedBox(width: 14.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Workout Reminder Time",

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
                              color: Colors.white.withOpacity(0.6),

                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios,

                      color: Colors.white.withOpacity(0.4),

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
        color: Colors.white.withOpacity(0.05),

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
                    color: Colors.white.withOpacity(0.5),

                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: value,

            activeColor: const Color(0xFF00E5FF),

            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
