import 'dart:async';

import 'package:fitness_app/core/di/injection_container.dart';

import 'package:fitness_app/core/services/notification_service.dart';
import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';

import 'package:fitness_app/features/notifications/presentation/bloc/notification_bloc.dart';

import 'package:fitness_app/features/notifications/presentation/bloc/notification_event.dart';

import 'package:fitness_app/features/notifications/presentation/bloc/notification_state.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  StreamSubscription? notificationSubscription;

  @override
  void initState() {
    super.initState();

    /// LIVE UPDATE LISTENER
    notificationSubscription = NotificationService
        .instance
        .notificationStreamController
        .stream
        .listen((_) {
          context.read<NotificationBloc>().add(LoadNotificationsEvent());
        });
  }

  @override
  void dispose() {
    notificationSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationBloc>()..add(LoadNotificationsEvent()),

      child: Scaffold(
        backgroundColor: const Color(0xFF050505),

        appBar: AppHeader(title: "Notifications"),

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
                          Colors.white.withOpacity(0.06),

                          Colors.white.withOpacity(0.02),
                        ],
                      ),

                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            color: const Color(0xFF00E5FF).withOpacity(0.12),
                          ),

                          child: Icon(
                            Icons.notifications,

                            color: const Color(0xFF00E5FF),

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
      ),
    );
  }
}
