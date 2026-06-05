import 'package:fitness_app/core/constants/education_data.dart';
import 'package:fitness_app/core/di/injection_container.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/core/widgets/education_bottom_sheet.dart';
import 'package:fitness_app/features/body_part_selection/presentation/pages/body_part_selection.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_event.dart';
import 'package:fitness_app/features/diet/presentation/pages/diet_detail_page.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_event.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_state.dart';
import 'package:fitness_app/features/health_metrics/domain/entities/health_metrics_entity.dart';
import 'package:fitness_app/features/health_metrics/presentation/bloc/health_metric_bloc.dart';
import 'package:fitness_app/features/health_metrics/presentation/bloc/health_metric_event.dart';
import 'package:fitness_app/features/health_metrics/presentation/bloc/health_metric_state.dart';
import 'package:fitness_app/features/health_metrics/presentation/widgets/add_metric_bottom_sheet.dart';
import 'package:fitness_app/features/home/presentation/widgets/active_diet_plan_card.dart';
import 'package:fitness_app/features/health_metrics/presentation/pages/health_metrics_chart.dart';
import 'package:fitness_app/features/home/presentation/widgets/home_header.dart';
import 'package:fitness_app/features/home/presentation/widgets/overall_health_card.dart';
import 'package:fitness_app/features/home/presentation/widgets/quick_action_section.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_state.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
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
  }

  @override
  void initState() {
    super.initState();

    context.read<ProfileBloc>().add(LoadProfileEvent());

    context.read<DietBloc>().add(LoadDietPlans());

    // context.read<AIInsightsBloc>().add(
    //   LoadAIInsightsEvent(
    //     steps: 12450,
    //     calories: 2200,
    //     streak: 18,
    //     bmi: 23.4,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B0B0B),
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
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, profileState) {
                          debugPrint(
                            "PROFILE STATE: ${profileState.runtimeType}",
                          );

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
                                          _buildGoalProgress(
                                            icon: Icons.directions_walk,
                                            title: "Steps",
                                            current: data.steps,
                                            goal: stepGoal,
                                            color: const Color(0xFF00E5FF),
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
                          context.push('/workout', extra: bodyPart);
                        },
                      ),
                      SizedBox(height: 16.h),
                      // AIInsightsSection(),
                      // SizedBox(height: 16.h),
                      BlocBuilder<DietBloc, DietState>(
                        builder: (context, state) {
                          DietPlanEntity? activePlan;

                          for (final plan in state.plans) {
                            if (plan.isActiveToday) {
                              activePlan = plan;
                              break;
                            }
                          }

                          print(
                            "HOME CARD => "
                            "name=${activePlan?.name} "
                            "active=${activePlan?.isActiveToday} "
                            "completed=${activePlan?.isCompletedToday}",
                          );

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
                                context.push('/diet-list');
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        child: Row(
                          children: [
                            _buildMetricChart(
                              context,
                              MetricType.heartRate,
                              "Heart Rate",
                              const Color(0xFFFF006E),
                            ),

                            SizedBox(width: 12.w),

                            _buildMetricChart(
                              context,
                              MetricType.sleep,
                              "Sleep",
                              const Color(0xFF5B8CFF),
                            ),

                            SizedBox(width: 12.w),

                            _buildMetricChart(
                              context,
                              MetricType.weight,
                              "Weight",
                              const Color(0xFF00E5FF),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      QuickActionsSection(
                        onCardTap: (key) async {
                          if (key == 'diet') {
                            context.push('/diet-list');
                          } else if (key == 'workout') {
                            context.push('/workout');
                          } else if (key == 'scanner') {
                            context.push('/barcode-food-entry');
                          } else if (key == 'food') {
                            context.push('/food-items');
                          } else if (key == 'calculator') {
                            context.push('/health-calculators');
                          } else if (key == 'history') {
                            context.push('/history');
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

  Widget _buildGoalProgress({
    required IconData icon,

    required String title,

    required int current,

    required int goal,

    required Color color,
  }) {
    final progress = (current / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Icon(icon, color: color),

            SizedBox(width: 10),

            Text(title, style: const TextStyle(color: Colors.white)),

            const Spacer(),

            Text(
              "$current / $goal",

              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),

          child: LinearProgressIndicator(
            value: progress,

            minHeight: 10.h,

            backgroundColor: Colors.white12,

            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricChart(
    BuildContext context,

    MetricType type,

    String title,

    Color color,
  ) {
    return BlocProvider(
      create: (_) => sl<HealthMetricsBloc>()..add(LoadHealthMetrics(type)),

      child: BlocBuilder<HealthMetricsBloc, HealthMetricState>(
        builder: (context, state) {
          if (state is HealthMetricLoading) {
            return const AppLoader();
          }

          if (state is HealthMetricError) {
            return SizedBox(
              width: 340.w,
              height: 220.h,

              child: Center(child: Text(state.message)),
            );
          }

          if (state is HealthMetricLoaded) {
            return SizedBox(
              width: 340.w,

              child: HealthMetricsChart(
                chartType: type,

                title: title,

                subtitle: "Last 7 days",

                metrics: state.metrics,

                color: color,

                onAddTap: () {
                  final bloc = context.read<HealthMetricsBloc>();

                  showModalBottomSheet(
                    context: context,

                    isScrollControlled: true,

                    backgroundColor: Colors.transparent,

                    builder: (_) {
                      return BlocProvider.value(
                        value: bloc,

                        child: AddMetricBottomSheet(type: type),
                      );
                    },
                  );
                },

                onRetry: () {
                  context.read<HealthMetricsBloc>().add(
                    LoadHealthMetrics(type),
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
