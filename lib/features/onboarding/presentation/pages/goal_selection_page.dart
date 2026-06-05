import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/onboarding_option_card.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

class GoalSelectionPage extends StatelessWidget {
  const GoalSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = [
      {"title": "Build Muscle", "emoji": "💪"},

      {"title": "Lose Weight", "emoji": "⚖"},

      {"title": "Stay Fit", "emoji": "🔥"},

      {"title": "Improve Strength", "emoji": "⚡"},
    ];

    return Scaffold(
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
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.12,
                      ),

                      /// TITLE
                      Text(
                        "What's Your Goal?",

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Colors.white,

                          fontSize: 34.sp,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      /// SUBTITLE
                      Text(
                        "Personalize your fitness experience",

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),

                          fontSize: 15.sp,
                        ),
                      ),

                      SizedBox(height: 40.h),

                      /// GOALS
                      Column(
                        children: goals.map((goal) {
                          final isSelected =
                              state.selectedGoal == goal["title"];

                          return OnboardingOptionCard(
                            title: goal["title"].toString(),

                            emoji: goal["emoji"].toString(),

                            isSelected: isSelected,

                            onTap: () {
                              context.read<OnboardingProfileBloc>().add(
                                SelectGoalEvent(goal["title"].toString()),
                              );
                            },
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 30.h),

                      /// CONTINUE BUTTON
                      SizedBox(
                        width: double.infinity,

                        height: 58.h,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: state.selectedGoal != null
                                ? const Color(0xFF00E5FF)
                                : Colors.grey.withOpacity(0.25),

                            disabledBackgroundColor: Colors.grey.withOpacity(
                              0.25,
                            ),

                            disabledForegroundColor: Colors.white,

                            elevation: 12,

                            shadowColor: const Color(
                              0xFF00E5FF,
                            ).withOpacity(0.4),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.r),
                            ),
                          ),

                          onPressed: state.selectedGoal == null
                              ? null
                              : () {
                                  context.push("/gender-selection");
                                },

                          child: Text(
                            "Continue",

                            style: TextStyle(
                              color: state.selectedGoal != null
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
    );
  }
}
