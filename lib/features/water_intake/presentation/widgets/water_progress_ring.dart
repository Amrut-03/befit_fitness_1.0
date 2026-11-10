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
    final size = 200.w;

    return Semantics(
      label: 'Water today: ${formatWater(totalMl)} of ${formatWater(goalMl)}',
      child: SizedBox.square(
        dimension: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: progress),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => CustomPaint(
            painter: _RingPainter(value),
            child: Center(
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
                    'of ${formatWater(goalMl)}',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    reached
                        ? 'Goal reached 🎉'
                        : '${formatWater(goalMl - totalMl)} to go',
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
