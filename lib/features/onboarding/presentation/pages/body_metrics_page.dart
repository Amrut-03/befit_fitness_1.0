import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_event.dart';

import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_state.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

class BodyMetricsPage extends StatelessWidget {
  const BodyMetricsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.08,
                      ),

                      /// TITLE
                      Text(
                        "Body Metrics",

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
                        "Help us calculate your fitness data",

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),

                          fontSize: 15.sp,
                        ),
                      ),

                      SizedBox(height: 50.h),

                      /// WEIGHT
                      _MetricCard(
                        title: "Weight",

                        value: state.weight.round(),

                        unit: "kg",

                        icon: Icons.monitor_weight,

                        min: 30,

                        max: 150,

                        onChanged: (value) {
                          context.read<OnboardingProfileBloc>().add(
                            UpdateWeightEvent(value),
                          );
                        },
                      ),

                      SizedBox(height: 24.h),

                      /// HEIGHT
                      _MetricCard(
                        title: "Height",

                        value: state.height.round(),

                        unit: "cm",

                        icon: Icons.height,

                        min: 100,

                        max: 230,

                        onChanged: (value) {
                          context.read<OnboardingProfileBloc>().add(
                            UpdateHeightEvent(value),
                          );
                        },
                      ),

                      SizedBox(height: 24.h),

                      /// AGE
                      _MetricCard(
                        title: "Age",

                        value: state.age.round(),

                        unit: "yrs",

                        icon: Icons.cake,

                        min: 10,

                        max: 80,

                        onChanged: (value) {
                          context.read<OnboardingProfileBloc>().add(
                            UpdateAgeEvent(value),
                          );
                        },
                      ),

                      SizedBox(height: 40.h),

                      /// CONTINUE BUTTON
                      SizedBox(
                        width: double.infinity,

                        height: 58.h,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),

                            elevation: 12,

                            shadowColor: const Color(
                              0xFF00E5FF,
                            ).withOpacity(0.4),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.r),
                            ),
                          ),

                          onPressed: () {
                            context.push('/activity-level');
                          },

                          child: Text(
                            "Continue",

                            style: TextStyle(
                              color: Colors.black,

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

class _MetricCard extends StatelessWidget {
  final String title;

  final int value;

  final String unit;

  final IconData icon;

  final double min;

  final double max;

  final Function(double) onChanged;

  const _MetricCard({
    required this.title,

    required this.value,

    required this.unit,

    required this.icon,

    required this.min,

    required this.max,

    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.w),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),

        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),

            Colors.white.withOpacity(0.02),
          ],
        ),

        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00E5FF), size: 28.sp),

              SizedBox(width: 12.w),

              Text(
                title,

                style: TextStyle(
                  color: Colors.white,

                  fontSize: 18.sp,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              Text(
                "$value $unit",

                style: TextStyle(
                  color: const Color(0xFF00E5FF),

                  fontSize: 24.sp,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00E5FF),

              inactiveTrackColor: Colors.white.withOpacity(0.08),

              thumbColor: const Color(0xFF00E5FF),

              overlayColor: const Color(0xFF00E5FF).withOpacity(0.15),
            ),

            child: Slider(
              value: value.toDouble(),

              min: min,

              max: max,

              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
