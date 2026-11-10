import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:fitness_app/features/profile/presentation/widgets/profile_settings_section.dart';
import 'package:fitness_app/features/profile/presentation/widgets/profile_share_section.dart';
import 'package:fitness_app/features/profile/presentation/widgets/profile_stats_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const AppLoader();
            }
            if (state is ProfileError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            if (state is! ProfileLoaded) {
              return const SizedBox();
            }

            final profile = state.profile;

            return SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(profile: profile),
                  SizedBox(height: 28.h),
                  _SectionTitle(context.l10n.profileFitnessStats),
                  SizedBox(height: 16.h),
                  ProfileStatsGrid(profile: profile),
                  SizedBox(height: 30.h),
                  _SectionTitle(context.l10n.profileShareProgress),
                  SizedBox(height: 16.h),
                  ProfileShareSection(profile: profile),
                  SizedBox(height: 16.h),
                  _SectionTitle(context.l10n.profileSettings),
                  SizedBox(height: 16.h),
                  ProfileSettingsSection(profile: profile),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
