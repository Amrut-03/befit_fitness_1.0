import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class OverallHealthWidget extends StatefulWidget {
  final double stepsPercentage;
  final double caloriesPercentage;
  final double moveMinPercentage;
  final double? overallHealthPercentage;
  final Color backgroundColor;
  final Color innerColor;
  final Color middleColor;
  final Color outerColor;
  final double strokeWidth;
  final double containerHeight;
  final double containerWidth;
  final double? arcSize;
  final int steps;
  final double calories;
  final int? moveMin;
  final String? previousSteps;
  final String? previousCalories;
  final String? previousMoveMin;
  final VoidCallback? onTap;
  final VoidCallback? onInfoTap;

  const OverallHealthWidget({
    super.key,
    required this.stepsPercentage,
    required this.caloriesPercentage,
    required this.moveMinPercentage,
    this.overallHealthPercentage,
    this.backgroundColor = Colors.black,
    this.innerColor = const Color(0xFF00E5FF),
    this.middleColor = const Color(0xFFFF6B35),
    this.outerColor = const Color(0xFFFF006E),
    this.strokeWidth = 12.0,
    this.containerHeight = 250,
    this.containerWidth = 230,
    this.arcSize,
    required this.steps,
    required this.calories,
    this.moveMin,
    this.previousSteps,
    this.previousCalories,
    this.previousMoveMin,
    this.onTap,
    this.onInfoTap,
  });

  @override
  State<OverallHealthWidget> createState() => _OverallHealthWidgetState();
}

class _OverallHealthWidgetState extends State<OverallHealthWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _stepsAnimation;
  late Animation<double> _caloriesAnimation;
  late Animation<double> _moveMinAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _stepsAnimation =
        Tween<double>(
          begin: 0,
          end: widget.stepsPercentage / 100 * 360,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _caloriesAnimation =
        Tween<double>(
          begin: 0,
          end: widget.caloriesPercentage / 100 * 360,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _moveMinAnimation =
        Tween<double>(
          begin: 0,
          end: widget.moveMinPercentage / 100 * 360,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(OverallHealthWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stepsPercentage != widget.stepsPercentage ||
        oldWidget.caloriesPercentage != widget.caloriesPercentage ||
        oldWidget.moveMinPercentage != widget.moveMinPercentage) {
      _stepsAnimation =
          Tween<double>(
            begin: oldWidget.stepsPercentage / 100 * 360,
            end: widget.stepsPercentage / 100 * 360,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            ),
          );

      _caloriesAnimation =
          Tween<double>(
            begin: oldWidget.caloriesPercentage / 100 * 360,
            end: widget.caloriesPercentage / 100 * 360,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            ),
          );

      _moveMinAnimation =
          Tween<double>(
            begin: oldWidget.moveMinPercentage / 100 * 360,
            end: widget.moveMinPercentage / 100 * 360,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            ),
          );

      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _calculateOverallPercentage() {
    if (widget.overallHealthPercentage != null) {
      return widget.overallHealthPercentage!;
    }
    final percentages = [
      widget.stepsPercentage,
      widget.caloriesPercentage,
      widget.moveMinPercentage,
    ];
    final sum = percentages.reduce((a, b) => a + b);
    return (sum / percentages.length).clamp(0.0, 100.0);
  }

  @override
  Widget build(BuildContext context) {
    final arcSizeValue = widget.arcSize ?? 190.w;

    return Column(
      children: [
        Container(
          height: widget.containerHeight.h,
          width: 250.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.backgroundColor,
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size(arcSizeValue, arcSizeValue),
                            painter: ConcentricArcsPainter(
                              innerSweepAngle: _stepsAnimation.value,
                              middleSweepAngle: _caloriesAnimation.value,
                              outerSweepAngle: _moveMinAnimation.value,
                              innerColor: widget.innerColor,
                              middleColor: widget.middleColor,
                              outerColor: widget.outerColor,
                              strokeWidth: widget.strokeWidth,
                            ),
                          ),
                          Text(
                            '${_calculateOverallPercentage().toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              if (widget.onInfoTap != null)
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onInfoTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

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
    final startAngle = -math.pi / 2;
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

    final outerStartAngle = startAngle + (math.pi / 6);
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

    final middleStartAngle =
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

    final innerStartAngle = startAngle - (math.pi / 8);
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

class CalculatorReadingsWidget extends StatelessWidget {
  final VoidCallback onClick;
  final int steps;
  final double calories;
  final int? moveMin;
  final String? previousSteps;
  final String? previousCalories;
  final String? previousMoveMin;

  const CalculatorReadingsWidget({
    super.key,
    required this.onClick,
    required this.steps,
    required this.calories,
    this.moveMin,
    this.previousSteps,
    this.previousCalories,
    this.previousMoveMin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FitnessReadingItem(
            onTap: onClick,
            lottieAsset: 'assets/lotties/steps.json',
            value: _formatSteps(steps),
            label: 'Steps',
            previousValue: previousSteps,
          ),
          Divider(
            indent: 8.w,
            endIndent: 8.w,
            color: Colors.grey.withOpacity(0.2),
          ),
          FitnessReadingItem(
            onTap: onClick,
            lottieAsset: 'assets/lotties/flame.json',
            value: calories.toStringAsFixed(0),
            label: 'Calories',
            bottomSpacing: 2.h,
            previousValue: previousCalories,
          ),
          Divider(
            indent: 8.w,
            endIndent: 8.w,
            color: Colors.grey.withOpacity(0.2),
          ),
          FitnessReadingItem(
            onTap: onClick,
            lottieAsset: 'assets/lotties/heart.json',
            value: moveMin != null ? moveMin!.toString() : '0',
            label: 'Move Min',
            lottieHeight: 25.h,
            lottieWidth: 25.w,
            topSpacing: 4.h,
            bottomSpacing: 3.h,
            previousValue: previousMoveMin,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000000) {
      return '${(steps / 1000000).toStringAsFixed(1)}M';
    } else if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}K';
    } else {
      return steps.toString();
    }
  }
}

class FitnessReadingItem extends StatefulWidget {
  final VoidCallback onTap;
  final String lottieAsset;
  final String value;
  final String label;
  final double? lottieHeight;
  final double? lottieWidth;
  final double? topSpacing;
  final double? bottomSpacing;
  final String? previousValue;
  final bool? isPositiveTrend;

  const FitnessReadingItem({
    super.key,
    required this.onTap,
    required this.lottieAsset,
    required this.value,
    required this.label,
    this.lottieHeight,
    this.lottieWidth,
    this.topSpacing,
    this.bottomSpacing,
    this.previousValue,
    this.isPositiveTrend,
  });

  @override
  State<FitnessReadingItem> createState() => _FitnessReadingItemState();
}

class _FitnessReadingItemState extends State<FitnessReadingItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _translateAnimation;
  double _previousValue = 0.0;
  final ValueNotifier<bool> _isAnimatingNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _translateAnimation = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _previousValue = _parseValue(widget.value);
  }

  double _parseValue(String value) {
    try {
      if (value.endsWith('K')) {
        return double.parse(value.replaceAll('K', '')) * 1000;
      } else if (value.endsWith('M')) {
        return double.parse(value.replaceAll('M', '')) * 1000000;
      }
      return double.parse(value);
    } catch (e) {
      return 0.0;
    }
  }

  bool _calculateTrend() {
    if (widget.isPositiveTrend != null) {
      return widget.isPositiveTrend!;
    }

    if (widget.previousValue == null) return false;

    try {
      final current = _parseValue(widget.value);
      final previous = _parseValue(widget.previousValue!);
      return current > previous;
    } catch (e) {
      return false;
    }
  }

  void _handleTap() {
    _isAnimatingNotifier.value = true;

    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        _isAnimatingNotifier.value = false;
      });
    });

    widget.onTap();
  }

  @override
  void didUpdateWidget(FitnessReadingItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final newValue = _parseValue(widget.value);
      if (newValue != _previousValue) {
        _previousValue = newValue;
        // Trigger number animation
        _animationController.forward(from: 0.0).then((_) {
          _animationController.reverse();
        });
      }
    }
  }

  @override
  void dispose() {
    _isAnimatingNotifier.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPositiveTrend = _calculateTrend();

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return ValueListenableBuilder<bool>(
            valueListenable: _isAnimatingNotifier,
            builder: (_, isAnimating, __) => Transform.translate(
              offset: Offset(0, _translateAnimation.value),
              child: Transform.scale(
                scale: isAnimating ? _scaleAnimation.value : 1.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: widget.topSpacing ?? 0),
                    SizedBox(
                      height: widget.lottieHeight ?? 35.h,
                      width: widget.lottieWidth ?? 35.h,
                      child: Transform.scale(
                        scale: 1.2,
                        child: Lottie.asset(
                          widget.lottieAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: widget.bottomSpacing ?? 5.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            widget.value,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (widget.previousValue != null ||
                            widget.isPositiveTrend != null) ...[
                          SizedBox(width: 4.w),
                          Icon(
                            hasPositiveTrend
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: hasPositiveTrend ? Colors.green : Colors.red,
                            size: 12.sp,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
