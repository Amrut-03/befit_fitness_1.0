import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickActionsSection extends StatelessWidget {
  final Future<void> Function(String)? onCardTap;

  const QuickActionsSection({super.key, this.onCardTap});

  final List<Map<String, dynamic>> _actions = const [
    {
      'icon': Icons.restaurant_menu,
      'title': 'qaDietPlan',
      'subtitle': 'qaDietPlanSub',
      'key': 'diet',
      'color': AppColors.primary,
    },

    {
      'icon': Icons.fitness_center,
      'title': 'qaWorkout',
      'subtitle': 'qaWorkoutSub',
      'key': 'workout',
      'color': AppColors.accentOrange,
    },

    {
      'icon': Icons.calculate,
      'title': 'qaCalculator',
      'subtitle': 'qaCalculatorSub',
      'key': 'calculator',
      'color': AppColors.primary,
    },

    {
      'icon': Icons.qr_code_scanner,
      'title': 'qaScanFood',
      'subtitle': 'qaScanFoodSub',
      'key': 'scanner',
      'color': Color(0xFF8338EC),
    },

    {
      'icon': Icons.fastfood,
      'title': 'qaMyFoods',
      'subtitle': 'qaMyFoodsSub',
      'key': 'food',
      'color': Color(0xFFFB5607),
    },

    {
      'icon': Icons.history,
      'title': 'historyTitle',
      'subtitle': 'qaHistorySub',
      'key': 'history',
      'color': AppColors.success,
    },
  ];

  /// Card texts are stored as l10n keys (the list is const).
  static String _text(AppLocalizations l10n, String key) => switch (key) {
    'qaDietPlan' => l10n.qaDietPlan,
    'qaDietPlanSub' => l10n.qaDietPlanSub,
    'qaWorkout' => l10n.qaWorkout,
    'qaWorkoutSub' => l10n.qaWorkoutSub,
    'qaCalculator' => l10n.qaCalculator,
    'qaCalculatorSub' => l10n.qaCalculatorSub,
    'qaScanFood' => l10n.qaScanFood,
    'qaScanFoodSub' => l10n.qaScanFoodSub,
    'qaMyFoods' => l10n.qaMyFoods,
    'qaMyFoodsSub' => l10n.qaMyFoodsSub,
    'historyTitle' => l10n.historyTitle,
    'qaHistorySub' => l10n.qaHistorySub,
    _ => key,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.homeQuickActions,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 14.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, index) {
            final item = _actions[index];

            return _ActionCard(
              icon: item['icon'],
              title: _text(context.l10n, item['title']),
              subtitle: _text(context.l10n, item['subtitle']),
              color: item['color'],
              onTap: () async {
                await onCardTap?.call(item['key']);
              },
            );
          },
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            // Grid cells have a fixed aspect ratio, so the subtitle gives way
            // on narrow screens or large text instead of overflowing.
            Flexible(
              child: Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
