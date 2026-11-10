import 'package:fitness_app/core/di/injection_container.dart';
import 'package:fitness_app/core/routes/routes.dart';
import 'package:fitness_app/core/session/session_notifier.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/onboarding/domain/utils/goal_calculator.dart';
import 'package:fitness_app/features/onboarding/domain/utils/macros_calculator.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/onboarding_option_card.dart';
import 'package:fitness_app/features/onboarding/presentation/widgets/onboarding_step_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivityLevelPage extends StatelessWidget {
  const ActivityLevelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final levels = [
      {"title": "Sedentary", "emoji": "🪑"},
      {"title": "Lightly Active", "emoji": "🚶"},
      {"title": "Active", "emoji": "🏃"},
      {"title": "Athlete", "emoji": "🔥"},
    ];

    return BlocListener<OnboardingProfileBloc, OnboardingProfileState>(
      listener: (context, state) {
        if (state.saveSuccess) {
          // The router redirects to /home once the session is ready.
          sl<SessionNotifier>().markProfileCompleted();
        }

        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.background,
                AppColors.surfaceNavy,
                AppColors.background,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: BlocBuilder<OnboardingProfileBloc, OnboardingProfileState>(
                  builder: (context, state) {
                    if (state.selectedGoal == null ||
                        state.selectedGender == null) {
                      return const OnboardingStepGuard(
                        canProceed: false,
                        fallbackRoute: Routes.genderSelection,
                        child: SizedBox.shrink(),
                      );
                    }

                    return Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.12,
                        ),
                        Text(
                          "Activity Level",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "Tell us about your daily activity",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(height: 40.h),
                        Column(
                          children: levels.map((level) {
                            final isSelected =
                                state.activityLevel == level["title"];

                            return OnboardingOptionCard(
                              title: level["title"].toString(),
                              emoji: level["emoji"].toString(),
                              isSelected: isSelected,
                              onTap: () {
                                context.read<OnboardingProfileBloc>().add(
                                  SelectActivityLevelEvent(
                                    level["title"].toString(),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 30.h),
                        SizedBox(
                          width: double.infinity,
                          height: 58.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.activityLevel != null
                                  ? AppColors.primary
                                  : Colors.grey.withValues(alpha: 0.25),
                              disabledBackgroundColor: Colors.grey.withValues(
                                alpha: 0.25,
                              ),
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                            onPressed:
                                state.activityLevel == null || state.isLoading
                                ? null
                                : () {
                                    final stepGoal =
                                        GoalCalculator.calculateStepGoal(
                                          state.selectedGoal ?? '',
                                          state.activityLevel ?? '',
                                        );

                                    final calorieGoal =
                                        GoalCalculator.calculateDailyCalories(
                                          gender: state.selectedGender ?? '',
                                          weight: state.weight,
                                          height: state.height,
                                          age: state.age.toInt(),
                                          activityLevel:
                                              state.activityLevel ?? '',
                                        );

                                    final macros = MacroCalculator.calculate(
                                      calories: calorieGoal,
                                      goal: state.selectedGoal ?? '',
                                    );

                                    final proteinGoal = macros['protein']!
                                        .round();

                                    final carbsGoal = macros['carbs']!.round();

                                    final fatGoal = macros['fat']!.round();

                                    context.read<OnboardingProfileBloc>().add(
                                      SaveProfileEvent(
                                        goal: state.selectedGoal ?? '',
                                        gender: state.selectedGender ?? '',
                                        weight: state.weight,
                                        height: state.height,
                                        age: state.age,
                                        activityLevel:
                                            state.activityLevel ?? '',
                                        dailyStepGoal: stepGoal,
                                        dailyCalorieGoal: calorieGoal,
                                        proteinGoal: proteinGoal,
                                        carbsGoal: carbsGoal,
                                        fatGoal: fatGoal,
                                      ),
                                    );
                                  },

                            child: state.isLoading
                                ? const AppLoader()
                                : Text(
                                    "Continue",
                                    style: TextStyle(
                                      color: state.activityLevel != null
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
