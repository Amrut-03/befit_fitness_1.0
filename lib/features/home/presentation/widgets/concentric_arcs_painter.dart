import 'dart:math' as math;

import 'package:flutter/material.dart';

class ConcentricArcsPainter extends CustomPainter {
  final double innerSweepAngle;
  final double middleSweepAngle;
  final double outerSweepAngle;
  final Color innerColor;
  final Color middleColor;
  final Color outerColor;
  final double strokeWidth;

  ConcentricArcsPainter({
    required this.innerSweepAngle,
    required this.middleSweepAngle,
    required this.outerSweepAngle,
    required this.innerColor,
    required this.middleColor,
    required this.outerColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const startAngle = -math.pi / 2;
    const greyColor = Color(0xFFE0E0E0);

    // Calculate radii for concentric circles
    final outerRadius = (size.width / 2) - strokeWidth / 2;
    final middleRadius = outerRadius - strokeWidth - 8;
    final innerRadius = middleRadius - strokeWidth - 8;

    // Calculate remaining angles (360 - sweep angle)
    final outerRemainingAngle = 360 - outerSweepAngle;
    final middleRemainingAngle = 360 - middleSweepAngle;
    final innerRemainingAngle = 360 - innerSweepAngle;

    // Draw outer arc background (grey) - unfilled portion
    final outerGreyPaint = Paint()
      ..color = greyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const outerStartAngle = startAngle + (math.pi / 6);
    final outerFilledAngle = outerSweepAngle * math.pi / 180;
    final outerGreyAngle = outerRemainingAngle * math.pi / 180;

    // Draw grey background (unfilled portion)
    if (outerRemainingAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        outerStartAngle + outerFilledAngle,
        outerGreyAngle,
        false,
        outerGreyPaint,
      );
    }

    // Draw outer arc (pink) - filled portion
    final outerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      outerStartAngle,
      outerFilledAngle,
      false,
      outerPaint,
    );

    // Draw middle arc background (grey) - unfilled portion
    final middleGreyPaint = Paint()
      ..color = greyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const middleStartAngle =
        startAngle - (math.pi / 12); // Start slightly to the left
    final middleFilledAngle = middleSweepAngle * math.pi / 180;
    final middleGreyAngle = middleRemainingAngle * math.pi / 180;

    // Draw grey background (unfilled portion)
    if (middleRemainingAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: middleRadius),
        middleStartAngle + middleFilledAngle,
        middleGreyAngle,
        false,
        middleGreyPaint,
      );
    }

    // Draw middle arc (orange) - filled portion
    final middlePaint = Paint()
      ..color = middleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: middleRadius),
      middleStartAngle,
      middleFilledAngle,
      false,
      middlePaint,
    );

    // Draw inner arc background (grey) - unfilled portion
    final innerGreyPaint = Paint()
      ..color = greyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const innerStartAngle = startAngle - (math.pi / 8);
    final innerFilledAngle = innerSweepAngle * math.pi / 180;
    final innerGreyAngle = innerRemainingAngle * math.pi / 180;

    // Draw grey background (unfilled portion)
    if (innerRemainingAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        innerStartAngle + innerFilledAngle,
        innerGreyAngle,
        false,
        innerGreyPaint,
      );
    }

    // Draw inner arc (teal) - filled portion
    final innerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      innerStartAngle,
      innerFilledAngle,
      false,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(ConcentricArcsPainter oldDelegate) {
    return oldDelegate.innerSweepAngle != innerSweepAngle ||
        oldDelegate.middleSweepAngle != middleSweepAngle ||
        oldDelegate.outerSweepAngle != outerSweepAngle ||
        oldDelegate.innerColor != innerColor ||
        oldDelegate.middleColor != middleColor ||
        oldDelegate.outerColor != outerColor;
  }
}
