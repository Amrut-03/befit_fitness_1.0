import 'package:fitness_app/core/l10n/l10n.dart';
import 'dart:math' as math;

import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'water_format.dart';

class WaterProgressRing extends StatelessWidget {
  const WaterProgressRing({
    super.key,
    required this.totalMl,
    required this.goalMl,
    required this.progress,
  });

  final int totalMl;
  final int goalMl;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final reached = totalMl >= goalMl;
    // Grows a little with the font size; the text inside scales down to fit
    // beyond that.
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    final size = 200.w * textScale;
    final status = reached
        ? context.l10n.waterGoalReached
        : context.l10n.waterToGo(formatWater(goalMl - totalMl));

    return Semantics(
      label:
          '${context.l10n.waterTodayLabel(formatWater(totalMl), formatWater(goalMl))}. $status',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: progress),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => CustomPaint(
            painter: _RingPainter(value),
            child: Padding(
              padding: EdgeInsets.all(size * 0.14),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.water_drop_rounded,
                      color: AppColors.water,
                      size: 28.sp,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      formatWater(totalMl),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      context.l10n.waterOfGoal(formatWater(goalMl)),
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      status,
                      style: TextStyle(
                        color: reached ? AppColors.success : AppColors.water,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.07;
    final rect =
        Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);

    final track = Paint()
      ..color = AppColors.water.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    if (progress <= 0) return;
    final arc = Paint()
      ..color = progress >= 1 ? AppColors.success : AppColors.water
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
