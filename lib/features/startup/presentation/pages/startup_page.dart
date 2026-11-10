import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/di/injection_container.dart';
import 'package:fitness_app/core/session/session_notifier.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';

/// Splash shown while [SessionNotifier] resolves the user and profile state.
/// The router moves off this page as soon as the status is known.
class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = sl<SessionNotifier>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: session,
        builder: (context, _) {
          final failed = session.status == SessionStatus.error;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fitness_center,
                  size: 70,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 20),
                const Text(
                  'BeFit',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                if (failed) ...[
                  Text(
                    context.l10n.startupProfileFailed,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: session.retry,
                    child: Text(context.l10n.commonRetry),
                  ),
                ] else
                  const AppLoader(),
              ],
            ),
          );
        },
      ),
    );
  }
}
