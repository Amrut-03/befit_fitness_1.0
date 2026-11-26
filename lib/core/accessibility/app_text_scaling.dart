import 'package:flutter/widgets.dart';

/// Follows the system font size, up to [maxScale].
///
/// Sizes are already adapted to the screen with ScreenUtil (`.sp`); the
/// user's font size is applied on top of that by [MediaQuery.textScaler].
/// Above [maxScale] (200% on Android 14, the larger accessibility sizes on
/// iOS) fixed-height cards and charts would clip, so it is capped there.
/// Screens are checked at [maxScale] in the widget tests.
class AppTextScaling extends StatelessWidget {
  const AppTextScaling({super.key, required this.child});

  static const double maxScale = 1.6;

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      MediaQuery.withClampedTextScaling(maxScaleFactor: maxScale, child: child);
}
