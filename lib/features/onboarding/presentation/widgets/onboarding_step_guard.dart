import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingStepGuard extends StatelessWidget {
  final bool canProceed;
  final String fallbackRoute;
  final Widget child;

  const OnboardingStepGuard({
    super.key,
    required this.canProceed,
    required this.fallbackRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (canProceed) {
      return child;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go(fallbackRoute);
      }
    });

    return const SizedBox.shrink();
  }
}
