import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/routes/routes.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../bloc/water_intake_bloc.dart';
import 'water_format.dart';

/// Home summary: today's water with one-tap logging. Tapping the card opens
/// the full Water page.
class WaterIntakeCard extends StatefulWidget {
  const WaterIntakeCard({super.key});

  @override
  State<WaterIntakeCard> createState() => _WaterIntakeCardState();
}

class _WaterIntakeCardState extends State<WaterIntakeCard> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<WaterIntakeBloc>();
    if (bloc.state.status == WaterStatus.initial) {
      bloc.add(const WaterIntakeStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WaterIntakeBloc>().state;
    final reached = state.today?.goalReached ?? false;
    final color = reached ? AppColors.success : AppColors.water;

    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: () => context.push(Routes.water),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wraps the amount onto its own line at large text sizes.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.w,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.water_drop_rounded, color: color, size: 22.sp),
                    SizedBox(width: 8.w),
                    Text(
                      context.l10n.waterTitle,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${formatWater(state.totalMl)} / ${formatWater(state.goalMl)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: state.progress,
                minHeight: 8.h,
                color: color,
                backgroundColor: AppColors.water.withValues(alpha: 0.15),
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 4.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final ml in const [250, 500]) _AddButton(ml: ml),
                if (reached)
                  Text(
                    context.l10n.waterGoalReached,
                    style: TextStyle(color: AppColors.success, fontSize: 12.sp),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.ml});

  final int ml;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.water,
        side: BorderSide(color: AppColors.water.withValues(alpha: 0.5)),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        visualDensity: VisualDensity.compact,
      ),
      onPressed: () => context.read<WaterIntakeBloc>().add(WaterAdded(ml)),
      icon: const Icon(Icons.add, size: 16),
      label: Text(formatWater(ml)),
    );
  }
}
