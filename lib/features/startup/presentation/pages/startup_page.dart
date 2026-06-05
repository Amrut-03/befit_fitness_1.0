import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/auth/presentation/pages/splash_redirect_page.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_state.dart';

import 'package:fitness_app/features/onboarding/presentation/pages/onboarding_page.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();

    context.read<OnboardingProfileBloc>().add(CheckProfileCompletedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingProfileBloc, OnboardingProfileState>(
      builder: (context, state) {
        /// LOADING
        if (state.isLoading) {
          return const Scaffold(body: Center(child: AppLoader()));
        }

        /// PROFILE COMPLETED
        if (state.profileSaved) {
          return const SplashRedirectPage();
        }

        /// SHOW ONBOARDING
        return const OnboardingScreen();
      },
    );
  }
}
