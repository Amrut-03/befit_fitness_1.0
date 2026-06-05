import 'dart:async';
import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_state.dart';
import 'package:fitness_app/features/workout/presentation/widgets/exercise_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutListPage extends StatefulWidget {
  final String? bodyPart;
  const WorkoutListPage({super.key, this.bodyPart});

  @override
  State<WorkoutListPage> createState() => _WorkoutListPageState();
}

class _WorkoutListPageState extends State<WorkoutListPage> {
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    context.read<WorkoutBloc>().add(
      LoadExercisesEvent(bodyPart: widget.bodyPart),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();

    _debounce?.cancel();

    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<WorkoutBloc>().add(SearchExercisesEvent(value));
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<WorkoutBloc>().add(const LoadExercisesEvent(loadMore: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppHeader(title: "Workouts"),
      body: BlocBuilder<WorkoutBloc, WorkoutState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const AppLoader();
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 60.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.error!,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WorkoutBloc>().add(
                        const LoadExercisesEvent(),
                      );
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
                child: Container(
                  height: 58.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 18.r,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: const Color(0xFF00E5FF),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                      prefixIcon: Container(
                        margin: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: const Color(0xFF00E5FF),
                          size: 22.sp,
                        ),
                      ),
                      hintText: "Search workouts...",
                      hintStyle: TextStyle(
                        color: Colors.white38,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      suffixIcon: state.searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () => _onSearchChanged(''),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white38,
                                size: 20.sp,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: state.exercises.isEmpty
                      ? Center(
                          child: Text(
                            "No exercises found",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16.sp,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: state.exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = state.exercises[index];

                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: _ExerciseCard(
                                exercise: exercise,
                                onTap: () =>
                                    showExerciseDetails(exercise, context),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseEntity exercise;
  final VoidCallback onTap;

  const _ExerciseCard({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: const Color(0xFF111111),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              child: exercise.gifUrl != null && exercise.gifUrl!.isNotEmpty
                  ? Image.network(
                      exercise.gifUrl!,
                      height: 200.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return _placeholder();
                      },
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _chip(exercise.bodyPart),
                      _chip(exercise.target),
                      _chip(exercise.equipment),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 200.h,
      color: Colors.white.withOpacity(0.05),
      child: Center(
        child: Icon(Icons.fitness_center, color: Colors.white24, size: 60.sp),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white70, fontSize: 11.sp),
      ),
    );
  }
}
