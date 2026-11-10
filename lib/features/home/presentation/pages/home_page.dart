import 'package:fitness_app/core/constants/education_data.dart';
import 'package:fitness_app/core/routes/routes.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/core/widgets/education_bottom_sheet.dart';
import 'package:fitness_app/features/ai_insights/presentation/widgets/ai_insights_section.dart';
import 'package:fitness_app/features/body_part_selection/presentation/pages/body_part_selection.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_event.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_state.dart';
import 'package:fitness_app/features/diet/presentation/pages/diet_detail_page.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_event.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_state.dart';
import 'package:fitness_app/features/health/presentation/widgets/health_platform_prompt.dart';
import 'package:fitness_app/core/health/health_platform_service.dart';
import 'package:fitness_app/features/health_metrics/domain/entities/health_metrics_entity.dart';
import 'package:fitness_app/features/home/presentation/widgets/active_diet_plan_card.dart';
import 'package:fitness_app/features/health_metrics/presentation/widgets/health_metric_card.dart';
import 'package:fitness_app/features/home/presentation/widgets/goal_progress_bar.dart';
import 'package:fitness_app/features/home/presentation/widgets/home_header.dart';
import 'package:fitness_app/features/home/presentation/widgets/calculator_readings_widget.dart';
import 'package:fitness_app/features/home/presentation/widgets/overall_health_card.dart';
import 'package:fitness_app/features/home/presentation/widgets/quick_action_section.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/progress_report/presentation/bloc/weekly_report_bloc.dart';
import 'package:fitness_app/features/progress_report/presentation/widgets/weekly_report_card.dart';
import 'package:fitness_app/features/water_intake/presentation/bloc/water_intake_bloc.dart';
import 'package:fitness_app/features/water_intake/presentation/widgets/water_intake_card.dart';
import 'package:fitness_app/features/workout/presentation/widgets/session/session_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../bloc/home_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _refresh() async {
    context.read<HomeBloc>().add(RefreshHomeDashboard());

    context.read<HealthBloc>().add(RefreshHealthData());

    context.read<WaterIntakeBloc>().add(const WaterIntakeRefreshed());

    context.read<WeeklyReportBloc>().add(const WeeklyReportRefreshed());
  }

  /// Re-reads steps (and the Health Connect status, e.g. after installing it
  /// from the Play Store) when the user returns to the app.
  late final AppLifecycleListener _lifecycle;

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _lifecycle = AppLifecycleListener(
      onResume: () {
        context.read<HealthBloc>().add(RefreshHealthData());
        // Moves the water log to the new day after midnight.
        context.read<WaterIntakeBloc>().add(const WaterIntakeRefreshed());
        context.read<WeeklyReportBloc>().add(const WeeklyReportRefreshed());
      },
    );

    context.read<ProfileBloc>().add(LoadProfileEvent());

    context.read<DietBloc>().add(LoadDietPlans());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const AppLoader();
            }

            if (state is HomeError) {
              return Center(child: Text(state.message));
            }

            if (state is HomeLoaded) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeHeader(userName: state.userName),
                      SizedBox(height: 20.h),
                      SessionBar(margin: EdgeInsets.only(bottom: 16.h)),
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, profileState) {
                          if (profileState is! ProfileLoaded) {
                            return const SizedBox();
                          }

                          final profile = profileState.profile;

                          return BlocBuilder<HealthBloc, HealthState>(
                            builder: (context, state) {
                              if (state is HealthLoading) {
                                return SizedBox(
                                  height: 250.h,
                                  child: const Center(child: AppLoader()),
                                );
                              }

                              if (state is HealthError) {
                                return SizedBox(
                                  height: 250.h,
                                  child: Center(
                                    child: Text(
                                      state.message,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              if (state is HealthLoaded) {
                                final data = state.data;
                                final stepGoal = profile.dailyStepGoal;

                                final calorieGoal = profile.dailyCalorieGoal;

                                return Column(
                                  children: [
                                    const HealthPlatformPrompt(),

                                    /// HEALTH SECTION
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: OverallHealthWidget(
                                            stepsPercentage:
                                                ((data.steps / stepGoal) * 100)
                                                    .clamp(0, 100),

                                            caloriesPercentage:
                                                ((data.calories / calorieGoal) *
                                                        100)
                                                    .clamp(0, 100),

                                            moveMinPercentage:
                                                ((data.moveMinutes / 60) * 100)
                                                    .clamp(0, 100),

                                            steps: data.steps,

                                            calories: data.calories,

                                            moveMin: data.moveMinutes,

                                            previousSteps: null,

                                            previousCalories: null,

                                            previousMoveMin: null,

                                            onTap: () {},
                                            onInfoTap: () {
                                              EducationBottomSheet.show(
                                                context,
                                                EducationData.overallHealth,
                                              );
                                            },
                                          ),
                                        ),

                                        SizedBox(width: 12.w),

                                        Expanded(
                                          flex: 1,
                                          child: CalculatorReadingsWidget(
                                            steps: data.steps,
                                            calories: data.calories,
                                            moveMin: data.moveMinutes,
                                            previousSteps: null,
                                            previousCalories: null,
                                            previousMoveMin: null,
                                            onClick: () {},
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 16.h),

                                    /// DAILY GOALS CARD
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(20.w),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Today's Goals",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 20.h),
                                          GoalProgressBar(
                                            icon: Icons.directions_walk,
                                            title: "Steps",
                                            current: data.steps,
                                            goal: stepGoal,
                                            color: AppColors.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox();
                            },
                          );
                        },
                      ),
                      SizedBox(height: 16.h),
                      BodyChartWidget(
                        onSearchWorkout: (bodyPart) {
                          context.push(Routes.workout, extra: bodyPart);
                        },
                      ),
                      SizedBox(height: 16.h),
                      const AIInsightsSection(),
                      SizedBox(height: 16.h),
                      const WeeklyReportCard(),
                      SizedBox(height: 16.h),
                      BlocBuilder<DietBloc, DietState>(
                        builder: (context, state) {
                          DietPlanEntity? activePlan;

                          for (final plan in state.plans) {
                            if (plan.isActiveToday) {
                              activePlan = plan;
                              break;
                            }
                          }

                          return ActiveDietPlanCard(
                            planName: activePlan?.name,
                            totalMeals: activePlan?.totalMeals,
                            consumedMeals: activePlan?.consumedMeals,
                            totalCalories: activePlan?.totalCalories,
                            progress: activePlan?.progress,
                            isCompletedToday:
                                activePlan?.isCompletedToday ?? false,
                            onTap: () {
                              if (activePlan == null) {
                                context.push(Routes.dietList);
                                return;
                              }

                              // if (activePlan.isCompletedToday) {
                              //   showDietCompletedBottomSheet(
                              //     context,
                              //     activePlan,
                              //   );
                              //   return;
                              // }
                              showDietDetailBottomSheet(context, activePlan);
                            },
                          );
                        },
                      ),
                      SizedBox(height: 16.h),
                      const WaterIntakeCard(),
                      SizedBox(height: 16.h),
                      SingleChildScrollView(
                        // Rebuild the self-loading cards once the health
                        // store is connected so they pick up its readings.
                        key: ValueKey(
                          context.select<HealthBloc, bool>(
                            (b) =>
                                b.state is HealthLoaded &&
                                (b.state as HealthLoaded).platformStatus ==
                                    HealthPlatformStatus.connected,
                          ),
                        ),
                        scrollDirection: Axis.horizontal,

                        child: Row(
                          children: [
                            const HealthMetricCard(
                              type: MetricType.heartRate,
                              title: "Heart Rate",
                              color: AppColors.accentPink,
                            ),

                            SizedBox(width: 12.w),

                            const HealthMetricCard(
                              type: MetricType.sleep,
                              title: "Sleep",
                              color: Color(0xFF5B8CFF),
                            ),

                            SizedBox(width: 12.w),

                            const HealthMetricCard(
                              type: MetricType.weight,
                              title: "Weight",
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      QuickActionsSection(
                        onCardTap: (key) async {
                          if (key == 'diet') {
                            await context.push(Routes.dietList);
                          } else if (key == 'workout') {
                            await context.push(Routes.workout);
                          } else if (key == 'scanner') {
                            await context.push(Routes.barcodeScanner);
                          } else if (key == 'food') {
                            await context.push(Routes.foodItems);
                          } else if (key == 'calculator') {
                            await context.push(Routes.healthCalculators);
                          } else if (key == 'history') {
                            await context.push(Routes.history);
                          }
                        },
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
