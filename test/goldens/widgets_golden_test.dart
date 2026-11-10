@Tags(['golden'])
library;

import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/home/presentation/widgets/quick_action_section.dart';
import 'package:fitness_app/features/profile/presentation/widgets/profile_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widgets/pump_app.dart';

/// Goldens capture only the target's own layers, so give it the app
/// background; otherwise white text renders on transparent.
Widget _onBackground(Widget child) => ColoredBox(
  key: const Key('golden'),
  color: AppColors.background,
  child: child,
);

void main() {
  testWidgets('quick actions grid', (tester) async {
    await tester.pumpApp(
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: _onBackground(const QuickActionsSection()),
          ),
        ),
      ),
    );

    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/quick_actions.png'),
    );
  });

  testWidgets('profile stat card', (tester) async {
    await tester.pumpApp(
      Scaffold(
        body: Center(
          child: SizedBox(
            width: 170,
            height: 140,
            child: _onBackground(
              const ProfileStatCard(
                title: 'Streak',
                value: '12 Days',
                icon: Icons.local_fire_department,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/profile_stat_card.png'),
    );
  });
}
