import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/entities/workout_session.dart';
import '../../cubit/workout_session_cubit.dart';

/// One exercise in the session: its sets with kg / reps / done.
class SessionExerciseCard extends StatelessWidget {
  const SessionExerciseCard({
    super.key,
    required this.index,
    required this.exercise,
    this.lastTime,
  });

  final int index;
  final SessionExercise exercise;

  /// "Last time: 3 × 10 @ 40 kg".
  final String? lastTime;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutSessionCubit>();

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 6.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      lastTime ?? exercise.bodyPart,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove exercise',
                icon: const Icon(Icons.close, color: AppColors.textMuted),
                onPressed: () => cubit.removeExercise(index),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          const _HeaderRow(),
          for (var i = 0; i < exercise.sets.length; i++)
            _SetRow(
              key: ValueKey('${exercise.exerciseId}_$i'),
              exerciseIndex: index,
              setIndex: i,
              set: exercise.sets[i],
            ),
          Wrap(
            children: [
              TextButton.icon(
                onPressed: () => cubit.addSet(index),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add set'),
              ),
              if (exercise.sets.length > 1)
                TextButton.icon(
                  onPressed: () =>
                      cubit.removeSet(index, exercise.sets.length - 1),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                  ),
                  icon: const Icon(Icons.remove, size: 18),
                  label: const Text('Remove set'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: AppColors.textMuted, fontSize: 11.sp);
    return Padding(
      padding: EdgeInsets.only(right: 8.w, bottom: 4.h),
      child: Row(
        children: [
          SizedBox(
            width: 32.w,
            child: Text('SET', style: style),
          ),
          Expanded(
            child: Text('KG', style: style, textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text('REPS', style: style, textAlign: TextAlign.center),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    super.key,
    required this.exerciseIndex,
    required this.setIndex,
    required this.set,
  });

  final int exerciseIndex;
  final int setIndex;
  final SessionSet set;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutSessionCubit>();
    final doneColor = AppColors.success.withValues(alpha: 0.12);

    return Container(
      color: set.done ? doneColor : null,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          SizedBox(
            width: 32.w,
            child: Text(
              '${setIndex + 1}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: _NumberField(
              label: 'Set ${setIndex + 1} weight in kg',
              value: set.weightKg == null ? '' : _kg(set.weightKg!),
              hint: '–',
              decimal: true,
              onChanged: (text) {
                final kg = double.tryParse(text.replaceAll(',', '.'));
                cubit.updateSet(
                  exerciseIndex,
                  setIndex,
                  weightKg: () => (kg == null || kg <= 0) ? null : kg,
                );
              },
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _NumberField(
              label: 'Set ${setIndex + 1} reps',
              value: '${set.reps}',
              hint: '0',
              onChanged: (text) {
                final reps = int.tryParse(text);
                if (reps != null) {
                  cubit.updateSet(exerciseIndex, setIndex, reps: reps);
                }
              },
            ),
          ),
          SizedBox(
            width: 48.w,
            child: IconButton(
              tooltip: set.done ? 'Mark set not done' : 'Complete set',
              onPressed: () {
                HapticFeedback.selectionClick();
                cubit.toggleSet(exerciseIndex, setIndex);
              },
              icon: Icon(
                set.done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: set.done ? AppColors.success : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _kg(double kg) =>
      kg == kg.roundToDouble() ? '${kg.toInt()}' : kg.toStringAsFixed(1);
}

/// A compact numeric field that follows [value] unless the user is typing.
class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.hint,
    required this.onChanged,
    this.decimal = false,
  });

  final String label;
  final String value;
  final String hint;
  final bool decimal;
  final ValueChanged<String> onChanged;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final _controller = TextEditingController(text: widget.value);
  final _focus = FocusNode();

  @override
  void didUpdateWidget(_NumberField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.numberWithOptions(decimal: widget.decimal),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            widget.decimal
                ? RegExp(r'^\d{0,3}([.,]\d{0,2})?')
                : RegExp(r'^\d{0,3}'),
          ),
        ],
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hint,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
