import 'package:fitness_app/features/workout/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showExerciseDetails(ExerciseEntity exercise, BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF111111),
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
                      errorBuilder: (_, __, ___) {
                        return Container(
                          height: 220.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
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
                            color: Color(0xFF00E5FF),
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

                SizedBox(
                  width: double.infinity,

                  height: 58.h,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),

                      elevation: 12,

                      shadowColor: const Color(0xFF00E5FF).withOpacity(0.4),

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

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF00E5FF),

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
                          "Complete Workout",

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
      color: const Color(0xFF00E5FF).withOpacity(0.12),
      borderRadius: BorderRadius.circular(30.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF00E5FF), size: 18.sp),
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
