import 'package:fitness_app/core/routes/routes.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../cubit/workout_session_cubit.dart';
import 'ticker.dart';

/// "Workout in progress" strip that opens the session. Hidden when no
/// session is running.
class SessionBar extends StatelessWidget {
  const SessionBar({super.key, this.margin});

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final session = context.select((WorkoutSessionCubit c) => c.state.session);
    if (session == null) return const SizedBox.shrink();

    final count = session.exercises.length;
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => context.push(Routes.workoutSession),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Icon(Icons.fitness_center, color: Colors.black, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Workout in progress · $count '
                    '${count == 1 ? 'exercise' : 'exercises'}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Ticker(
                  builder: (_, now) => Text(
                    formatDuration(now.difference(session.startedAt)),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
