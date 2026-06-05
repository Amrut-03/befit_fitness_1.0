import 'package:fitness_app/core/constants/education_data.dart';
import 'package:fitness_app/core/widgets/education_bottom_sheet.dart';
import 'package:fitness_app/features/body_part_selection/presentation/bloc/body_part_selection_bloc.dart';
import 'package:fitness_app/features/body_part_selection/presentation/bloc/body_part_selection_event.dart';
import 'package:fitness_app/features/body_part_selection/presentation/bloc/body_part_selection_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_body_part_selector/feature/flutter_body_part_selector/domain/entities/muscle.dart';
import 'package:flutter_body_part_selector/feature/flutter_body_part_selector/presentation/widgets/interactive_body_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BodyChartWidget extends StatelessWidget {
  final Function(String bodyPart)? onSearchWorkout;

  const BodyChartWidget({super.key, this.onSearchWorkout});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BodySelectionBloc, BodySelectionState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Body Chart',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      EducationBottomSheet.show(
                        context,
                        EducationData.bodyChart,
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (state.selectedMuscles.isNotEmpty) ...[
                _buildSelectedHeader(context, state),
                SizedBox(height: 10.h),
              ],
              SizedBox(
                height: 450.h,
                child: Row(
                  children: [
                    Expanded(flex: 3, child: _buildBodySection(context, state)),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: _buildPickerSection(context, state),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedHeader(BuildContext context, BodySelectionState state) {
    return GestureDetector(
      onTap: () {
        final bodyPart = getPrimaryBodyPart(state.selectedMuscles);

        if (bodyPart != null) {
          debugPrint("Selected Body Part: $bodyPart");

          onSearchWorkout?.call(bodyPart);
        }
      },

      child: Container(
        width: double.infinity,

        padding: EdgeInsets.symmetric(vertical: 12.h),

        decoration: BoxDecoration(
          color: const Color(0xFF00E5FF),

          borderRadius: BorderRadius.circular(8.r),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.search, color: Colors.black, size: 18.sp),

            SizedBox(width: 8.w),

            Text(
              'Search Workouts',

              style: TextStyle(
                color: Colors.black,

                fontSize: 14.sp,

                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodySection(BuildContext context, BodySelectionState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                state.isFront ? 'Front' : 'Back',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<BodySelectionBloc>().add(ToggleView());
              },
              icon: Icon(Icons.flip, color: Colors.white, size: 20.sp),
            ),
          ],
        ),
        SizedBox(height: 4.h),

        Expanded(
          child: InteractiveBodySvg(
            isFront: state.isFront,
            selectedMuscles: state.selectedMuscles,
            disabledMuscles: state.disabledMuscles,
            highlightColor: const Color(0xFF00E5FF),
            disabledColor: Colors.grey,
            selectedStrokeWidth: 2.5,
            unselectedStrokeWidth: 1.0,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            hitTestPadding: 5,
            tooltipBuilder: (muscle) => muscle.displayName,
            onMuscleTap: (m) {
              context.read<BodySelectionBloc>().add(ToggleMuscle(m));
            },
            onMuscleLongPress: (m) {
              context.read<BodySelectionBloc>().add(ToggleDisableMuscle(m));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPickerSection(BuildContext context, BodySelectionState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Text(
              'Muscles',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: _buildMusclePicker(context, state)),
        ],
      ),
    );
  }

  Widget _buildMusclePicker(BuildContext context, BodySelectionState state) {
    final all = Muscle.values;

    final frontMuscles = all
        .where(
          (m) =>
              m == Muscle.chestLeft ||
              m == Muscle.chestRight ||
              m == Muscle.deltsLeft ||
              m == Muscle.deltsRight ||
              m == Muscle.bicepsLeft ||
              m == Muscle.bicepsRight ||
              m == Muscle.tricepsLeft ||
              m == Muscle.tricepsRight ||
              m == Muscle.forearmsLeft ||
              m == Muscle.forearmsRight ||
              m == Muscle.abs ||
              m == Muscle.quadsLeft ||
              m == Muscle.quadsRight ||
              m == Muscle.calvesLeft ||
              m == Muscle.calvesRight ||
              m == Muscle.trapsLeft ||
              m == Muscle.trapsRight,
        )
        .toList();

    final backMuscles = all
        .where(
          (m) =>
              m == Muscle.latsBackLeft ||
              m == Muscle.latsBackRight ||
              m == Muscle.lowerLatsBackLeft ||
              m == Muscle.lowerLatsBackRight ||
              m == Muscle.glutesLeft ||
              m == Muscle.glutesRight ||
              m == Muscle.hamstringsLeft ||
              m == Muscle.hamstringsRight,
        )
        .toList();

    final list = state.isFront ? frontMuscles : backMuscles;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      children: [_buildMuscleSection(context, list, state)],
    );
  }

  Widget _buildMuscleSection(
    BuildContext context,
    List<Muscle> muscles,
    BodySelectionState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: muscles.map((muscle) {
        final selected = state.selectedMuscles.contains(muscle);
        final disabled = state.disabledMuscles.contains(muscle);

        return Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: GestureDetector(
            onTap: () {
              context.read<BodySelectionBloc>().add(ToggleMuscle(muscle));
            },
            onLongPress: () {
              context.read<BodySelectionBloc>().add(
                ToggleDisableMuscle(muscle),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: disabled
                    ? Colors.grey.withOpacity(0.15)
                    : selected
                    ? const Color(0xFF00E5FF).withOpacity(0.3)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: disabled
                      ? Colors.grey
                      : selected
                      ? const Color(0xFF00E5FF)
                      : Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      muscle.displayName,
                      style: TextStyle(
                        color: disabled
                            ? Colors.grey
                            : selected
                            ? const Color(0xFF00E5FF)
                            : Colors.white,
                        fontSize: 11.sp,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF00E5FF),
                      size: 16.sp,
                    ),
                  if (disabled)
                    Icon(Icons.lock, color: Colors.grey, size: 14.sp),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String? getPrimaryBodyPart(Set<Muscle> selectedMuscles) {
    if (selectedMuscles.isEmpty) return null;

    final counts = <String, int>{};

    for (final muscle in selectedMuscles) {
      final bodyPart = _muscleToBodyPart(muscle);
      if (bodyPart == null) continue;

      counts[bodyPart] = (counts[bodyPart] ?? 0) + 1;
    }

    if (counts.isEmpty) return null;

    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String? _muscleToBodyPart(Muscle muscle) {
    switch (muscle) {
      case Muscle.chestLeft:
      case Muscle.chestRight:
        return 'chest';

      case Muscle.deltsLeft:
      case Muscle.deltsRight:
      case Muscle.trapsLeft:
      case Muscle.trapsRight:
        return 'shoulders';

      case Muscle.bicepsLeft:
      case Muscle.bicepsRight:
      case Muscle.tricepsLeft:
      case Muscle.tricepsRight:
      case Muscle.forearmsLeft:
      case Muscle.forearmsRight:
        return 'upper arms';

      case Muscle.latsBackLeft:
      case Muscle.latsBackRight:
      case Muscle.lowerLatsBackLeft:
      case Muscle.lowerLatsBackRight:
        return 'back';

      case Muscle.abs:
        return 'waist';

      case Muscle.quadsLeft:
      case Muscle.quadsRight:
      case Muscle.hamstringsLeft:
      case Muscle.hamstringsRight:
      case Muscle.calvesLeft:
      case Muscle.calvesRight:
      case Muscle.glutesLeft:
      case Muscle.glutesRight:
        return 'upper legs';
    }
  }
}
