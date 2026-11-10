import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

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
            builder: (_, isAnimating, _) => Transform.translate(
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
