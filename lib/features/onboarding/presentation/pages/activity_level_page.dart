import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/onboarding/domain/utils/goal_calculator.dart';
import 'package:fitness_app/features/onboarding/domain/utils/macros_calculator.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/onboarding_option_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
          context.go('/home');
        }

        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF050505),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF050505), Color(0xFF09111F), Color(0xFF050505)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: BlocBuilder<OnboardingProfileBloc, OnboardingProfileState>(
                  builder: (context, state) {
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
                            color: Colors.white.withOpacity(0.6),
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
                                  ? const Color(0xFF00E5FF)
                                  : Colors.grey.withOpacity(0.25),
                              disabledBackgroundColor: Colors.grey.withOpacity(
                                0.25,
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
                                ? AppLoader()
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
