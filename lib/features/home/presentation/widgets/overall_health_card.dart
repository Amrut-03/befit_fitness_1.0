import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/info_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/features/home/presentation/widgets/concentric_arcs_painter.dart';

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
    this.innerColor = AppColors.primary,
    this.middleColor = AppColors.accentOrange,
    this.outerColor = AppColors.accentPink,
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
                child: Semantics(
                  label: context.l10n.a11yOverallHealth(
                    _calculateOverallPercentage().toStringAsFixed(0),
                    widget.steps,
                    widget.calories.round(),
                    widget.moveMin ?? 0,
                  ),
                  excludeSemantics: true,
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
              ),
              if (widget.onInfoTap != null)
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: InfoButton(onPressed: widget.onInfoTap!),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
