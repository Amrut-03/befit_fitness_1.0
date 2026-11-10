import 'package:fitness_app/core/routes/routes.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_event.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:fitness_app/features/workout/presentation/cubit/workout_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

void showExerciseDetails(ExerciseEntity exercise, BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),

    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (context, controller) {
          return SingleChildScrollView(
            controller: controller,
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                if (exercise.gifUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22.r),
                    child: Image.network(
                      exercise.gifUrl!,
                      height: 220.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Container(
                          height: 220.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(22.r),
                          ),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: Colors.white38,
                            size: 60.sp,
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 24.h),
                Text(
                  exercise.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: [
                    _infoChip(exercise.bodyPart, Icons.accessibility_new),
                    _infoChip(exercise.target, Icons.local_fire_department),
                    _infoChip(exercise.equipment, Icons.fitness_center),
                  ],
                ),
                SizedBox(height: 28.h),
                Text(
                  "Instructions",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                if (exercise.instructions.isEmpty)
                  Text(
                    "No instructions available",
                    style: TextStyle(color: Colors.white60, fontSize: 14.sp),
                  ),

                ...exercise.instructions.asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "${entry.key + 1}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14.sp,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 30.h),

                _AddToSessionAction(exercise: exercise),

                SizedBox(height: 12.h),

                SizedBox(
                  width: double.infinity,

                  height: 58.h,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,

                      elevation: 12,

                      shadowColor: AppColors.primary.withValues(alpha: 0.4),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),

                    onPressed: () {
                      context.read<WorkoutBloc>().add(
                        SaveWorkoutHistoryEvent(
                          workoutName: exercise.name,

                          bodyPart: exercise.bodyPart,

                          exercises: [exercise.name],
                        ),
                      );

                      // A saved workout counts as today's activity.
                      context.read<StreakBloc>().add(UpdateStreakEvent());

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primary,

                          behavior: SnackBarBehavior.floating,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),

                          content: Text(
                            "Workout Completed 🔥",

                            style: TextStyle(
                              color: Colors.black,

                              fontSize: 14.sp,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.check_circle_rounded,

                          color: Colors.black,

                          size: 22.sp,
                        ),

                        SizedBox(width: 10.w),

                        Text(
                          "Log as done",

                          style: TextStyle(
                            color: Colors.black,

                            fontSize: 16.sp,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _infoChip(String text, IconData icon) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(30.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 18.sp),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

/// Adds the exercise to the workout session and opens it.
class _AddToSessionAction extends StatelessWidget {
  const _AddToSessionAction({required this.exercise});

  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context) {
    final added = context.select(
      (WorkoutSessionCubit c) => c.state.contains(exercise.id),
    );
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        onPressed: () async {
          if (!added) {
            await context.read<WorkoutSessionCubit>().addExercise(exercise);
          }
          if (!context.mounted) return;
          // The sheet's context is gone once it closes.
          final router = GoRouter.of(context);
          Navigator.pop(context);
          await router.push(Routes.workoutSession);
        },
        icon: Icon(added ? Icons.play_arrow_rounded : Icons.add),
        label: Text(added ? 'Open workout' : 'Add to workout & start'),
      ),
    );
  }
}
