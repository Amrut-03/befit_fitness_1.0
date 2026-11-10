import 'dart:async';

import 'package:fitness_app/core/di/injection_container.dart';
import 'package:fitness_app/core/services/notification_service.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:fitness_app/features/notifications/presentation/bloc/notification_event.dart';
import 'package:fitness_app/features/notifications/presentation/bloc/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationBloc>()..add(LoadNotificationsEvent()),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatefulWidget {
  const _NotificationView();

  @override
  State<_NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<_NotificationView> {
  StreamSubscription? notificationSubscription;

  @override
  void initState() {
    super.initState();

    final bloc = context.read<NotificationBloc>();

    /// LIVE UPDATE LISTENER
    notificationSubscription = NotificationService
        .instance
        .notificationStreamController
        .stream
        .listen((_) {
          if (!mounted) return;

          bloc.add(LoadNotificationsEvent());
        });
  }

  @override
  void dispose() {
    notificationSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: const AppHeader(title: "Notifications"),

      body: RefreshIndicator(
        onRefresh: () async {
          context.read<NotificationBloc>().add(LoadNotificationsEvent());
        },

        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            /// LOADING
            if (state.isLoading) {
              return const AppLoader();
            }

            /// EMPTY
            if (state.notifications.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: 250.h),

                  Column(
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,

                        color: Colors.white24,

                        size: 70.sp,
                      ),

                      SizedBox(height: 18.h),

                      Text(
                        "No Notifications Yet",

                        style: TextStyle(
                          color: Colors.white70,

                          fontSize: 16.sp,

                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(20.w),

              itemCount: state.notifications.length,

              itemBuilder: (context, index) {
                final notification = state.notifications[index];

                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),

                  padding: EdgeInsets.all(18.w),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),

                    gradient: LinearGradient(
                      begin: Alignment.topLeft,

                      end: Alignment.bottomRight,

                      colors: [
                        Colors.white.withValues(alpha: 0.06),

                        Colors.white.withValues(alpha: 0.02),
                      ],
                    ),

                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          color: AppColors.primary.withValues(alpha: 0.12),
                        ),

                        child: Icon(
                          Icons.notifications,

                          color: AppColors.primary,

                          size: 22.sp,
                        ),
                      ),

                      SizedBox(width: 16.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              notification.title,

                              style: TextStyle(
                                color: Colors.white,

                                fontSize: 15.sp,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 6.h),

                            Text(
                              notification.body,

                              style: TextStyle(
                                color: Colors.white70,

                                fontSize: 13.sp,

                                height: 1.5,
                              ),
                            ),

                            SizedBox(height: 12.h),

                            Text(
                              DateFormat(
                                'dd MMM yyyy • hh:mm a',
                              ).format(notification.createdAt),

                              style: TextStyle(
                                color: Colors.white38,

                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
