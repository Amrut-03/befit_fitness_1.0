import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/routes/routes.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();

  int currentPage = 0;

  final List<Map<String, String>> items = [
    {"image": "assets/lotties/self_work_out.json"},
    {"image": "assets/lotties/nutrition.json"},
    {"image": "assets/lotties/consistent.json"},
  ];

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingProfileBloc, OnboardingProfileState>(
      builder: (context, state) {
        return Scaffold(
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
              child: Column(
                children: [
                  /// TOP BAR
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,

                      vertical: 16.h,
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        /// PAGE INDICATOR
                        Row(
                          children: List.generate(items.length, (index) {
                            final isActive = currentPage == index;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),

                              margin: EdgeInsets.only(right: 6.w),

                              width: isActive ? 24.w : 8.w,

                              height: 8.h,

                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.15),

                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            );
                          }),
                        ),

                        /// SKIP
                        TextButton(
                          onPressed: () {
                            context.go(Routes.login);
                          },

                          child: Text(
                            context.l10n.commonSkip,

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: 15.sp,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// PAGEVIEW
                  Expanded(
                    child: PageView.builder(
                      controller: controller,

                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },

                      itemCount: items.length,

                      itemBuilder: (context, index) {
                        final item = items[index];
                        final l10n = context.l10n;
                        final (title, description) = switch (index) {
                          0 => (l10n.onbTrackTitle, l10n.onbTrackBody),
                          1 => (l10n.onbNutritionTitle, l10n.onbNutritionBody),
                          _ => (
                            l10n.onbConsistentTitle,
                            l10n.onbConsistentBody,
                          ),
                        };

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),

                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                /// LOTTIE
                                Container(
                                  height: 320.h,

                                  width: 320.w,

                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.primary.withValues(
                                          alpha: 0.15,
                                        ),

                                        Colors.transparent,
                                      ],
                                    ),
                                  ),

                                  child: Lottie.asset(
                                    item['image'] ?? '',

                                    fit: BoxFit.contain,
                                  ),
                                ).animate().fade().slideY(begin: 0.2),

                                SizedBox(height: 40.h),

                                /// TITLE
                                Text(
                                  title,

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    color: Colors.white,

                                    fontSize: 34.sp,

                                    height: 1.2,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ).animate().fade().slideY(begin: 0.2),

                                SizedBox(height: 20.h),

                                /// DESCRIPTION
                                Text(
                                  description,

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),

                                    fontSize: 15.sp,

                                    height: 1.7,
                                  ),
                                ).animate().fade().slideY(begin: 0.2),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  /// BUTTON
                  Padding(
                    padding: EdgeInsets.all(24.w),

                    child: SizedBox(
                      width: double.infinity,

                      height: 60.h,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,

                          elevation: 12,

                          shadowColor: AppColors.primary.withValues(alpha: 0.4),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.r),
                          ),
                        ),

                        onPressed: () {
                          /// LAST PAGE
                          if (currentPage == items.length - 1) {
                            context.go(Routes.login);

                            return;
                          }

                          /// NEXT PAGE
                          controller.nextPage(
                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Text(
                          currentPage == items.length - 1
                              ? context.l10n.onbGetStarted
                              : context.l10n.commonContinue,

                          style: TextStyle(
                            color: Colors.black,

                            fontSize: 17.sp,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
