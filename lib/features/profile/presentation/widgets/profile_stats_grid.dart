import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/presentation/widgets/profile_stat_card.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileStatsGrid extends StatelessWidget {
  const ProfileStatsGrid({super.key, required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14.w,
      mainAxisSpacing: 14.h,
      childAspectRatio: 1.2,
      children: [
        ProfileStatCard(
          title: context.l10n.statWeight,
          value: context.l10n.unitKg(profile.weight.round().toString()),
          icon: Icons.monitor_weight,
          color: AppColors.primary,
        ),
        ProfileStatCard(
          title: context.l10n.statHeight,
          value: context.l10n.unitCm(profile.height.round().toString()),
          icon: Icons.height,
          color: AppColors.warning,
        ),
        ProfileStatCard(
          title: context.l10n.statAge,
          value: "${profile.age.round()}",
          icon: Icons.cake,
          color: AppColors.accentPink,
        ),
        BlocBuilder<StreakBloc, StreakState>(
          builder: (context, state) {
            if (state.isLoading) {
              return ProfileStatCard(
                title: context.l10n.statStreak,
                value: "...",
                icon: Icons.local_fire_department,
                color: AppColors.primary,
              );
            }

            return ProfileStatCard(
              title: context.l10n.statStreak,
              value: context.l10n.daysCount(state.currentStreak),
              icon: Icons.local_fire_department,
              color: AppColors.primary,
            );
          },
        ),
      ],
    );
  }
}
