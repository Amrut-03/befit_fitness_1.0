import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The small round "i" that opens an explainer. A full-size (48 dp) tap
/// target with a "Learn more" label for screen readers.
class InfoButton extends StatelessWidget {
  const InfoButton({super.key, required this.onPressed, this.tooltip});

  final VoidCallback onPressed;

  /// Defaults to "Learn more".
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip ?? context.l10n.a11yLearnMore,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.08),
      ),
      icon: Icon(Icons.info_outline, color: Colors.white, size: 18.sp),
    );
  }
}
