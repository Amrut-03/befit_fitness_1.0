import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/routes/routes.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_event.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_state.dart';
import 'package:fitness_app/features/diet/presentation/pages/diet_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class DietListPage extends StatefulWidget {
  const DietListPage({super.key});

  @override
  State<DietListPage> createState() => _DietListPageState();
}

class _DietListPageState extends State<DietListPage> {
  @override
  void initState() {
    super.initState();

    final bloc = context.read<DietBloc>();

    bloc.add(LoadDietPlans());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      appBar: AppHeader(title: context.l10n.dietPlanningTitle),
      body: BlocBuilder<DietBloc, DietState>(
        builder: (context, state) {
          final visiblePlans = state.plans;

          if (state.isLoading && state.plans.isEmpty && state.error == null) {
            return const AppLoader();
          }
          if (state.error != null) {
            return Center(
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (state.plans.isEmpty || visiblePlans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80.sp,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),

                  SizedBox(height: 16.h),

                  Text(
                    context.l10n.dietNoPlans,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 18.sp,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    context.l10n.dietNoPlansHint,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: visiblePlans.length,
            itemBuilder: (context, index) {
              final plan = visiblePlans[index];
              return _buildPlanCard(context, plan);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "plan_your_diet_button",
        onPressed: () async {
          await context.push(Routes.planDiet);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.restaurant_menu, color: Colors.black),
        label: Text(
          context.l10n.dietPlanYourDiet,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeletePlan(
    BuildContext context,
    DietPlanEntity plan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            context.l10n.dietDeleteTitle,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            context.l10n.dietDeleteConfirm(plan.name),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                context.l10n.commonCancel,
                style: const TextStyle(color: Colors.white60),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                context.l10n.commonDelete,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      context.read<DietBloc>().add(DeleteDietPlanEvent(plan.id));
    }
  }

  Widget _buildPlanCard(BuildContext context, DietPlanEntity plan) {
    return GestureDetector(
      onTap: () {
        showDietDetailBottomSheet(context, plan);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: plan.isActiveToday
                ? [AppColors.primary.withValues(alpha: 0.15), Colors.black]
                : [AppColors.surfaceHigh, Colors.black],
          ),
          border: Border.all(
            color: plan.isActiveToday ? AppColors.primary : Colors.white10,
            width: 1.2,
          ),
          boxShadow: [
            if (plan.isActiveToday)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    color: AppColors.primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        context.l10n.dietMealsCount(plan.totalMeals),
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: plan.isActiveToday
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                      color: plan.isActiveToday ? Colors.green : Colors.white24,
                    ),
                  ),
                  child: Text(
                    plan.isActiveToday
                        ? context.l10n.dietCardActiveBadge
                        : context.l10n.dietInactiveBadge,
                    style: TextStyle(
                      color: plan.isActiveToday
                          ? Colors.greenAccent
                          : Colors.white54,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.statCalories,
                  style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                ),
                Text(
                  context.l10n.unitKcal(plan.totalCalories.toInt().toString()),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: LinearProgressIndicator(
                value: plan.progress,
                minHeight: 10.h,
                backgroundColor: Colors.white10,
                color: plan.isActiveToday ? AppColors.primary : Colors.blue,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.dietMealsCompleted(
                    plan.consumedMeals,
                    plan.totalMeals,
                  ),
                  style: TextStyle(color: Colors.white60, fontSize: 12.sp),
                ),
                Text(
                  "${(plan.progress * 100).toInt()}%",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<DietBloc>().add(
                        SetActiveDietPlanEvent(plan.id),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: plan.isActiveToday
                            ? Colors.green
                            : AppColors.primary,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    icon: Icon(
                      Icons.bolt,
                      color: plan.isActiveToday
                          ? Colors.green
                          : AppColors.primary,
                      size: 18.sp,
                    ),
                    label: Text(
                      plan.isActiveToday
                          ? context.l10n.dietActivated
                          : context.l10n.dietSetActive,
                      style: TextStyle(
                        color: plan.isActiveToday
                            ? Colors.green
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: IconButton(
                    onPressed: () {
                      context.push(Routes.planDiet, extra: plan);
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: IconButton(
                    onPressed: () => _confirmDeletePlan(context, plan),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
