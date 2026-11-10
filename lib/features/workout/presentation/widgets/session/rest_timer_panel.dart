import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/entities/workout_session.dart';
import '../../cubit/workout_session_cubit.dart';
import 'ticker.dart';

/// Countdown shown while resting between sets, with ±15 s and Skip.
/// Buzzes when the rest is over.
class RestTimerPanel extends StatefulWidget {
  const RestTimerPanel({super.key, required this.session, this.clock});

  final WorkoutSession session;
  final DateTime Function()? clock;

  @override
  State<RestTimerPanel> createState() => _RestTimerPanelState();
}

class _RestTimerPanelState extends State<RestTimerPanel> {
  bool _wasResting = false;

  void _onTick(bool resting) {
    if (_wasResting && !resting) {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
    }
    _wasResting = resting;
  }

  @override
  Widget build(BuildContext context) {
    return Ticker(
      clock: widget.clock,
      builder: (context, now) {
        final s = widget.session;
        final resting = s.isResting(now);
        _onTick(resting);
        if (!resting) return const SizedBox.shrink();

        final remaining = s.restRemaining(now);
        final progress = remaining.inMilliseconds / (s.restSeconds * 1000);
        final cubit = context.read<WorkoutSessionCubit>();

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceNavy,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Rest',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatDuration(
                      remaining + const Duration(milliseconds: 999),
                    ),
                    semanticsLabel: 'Rest remaining',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              LinearProgressIndicator(
                value: progress.clamp(0, 1),
                color: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  TextButton(
                    onPressed: () => cubit.adjustRest(-15),
                    child: const Text('−15 s'),
                  ),
                  TextButton(
                    onPressed: () => cubit.adjustRest(15),
                    child: const Text('+15 s'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: cubit.skipRest,
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
