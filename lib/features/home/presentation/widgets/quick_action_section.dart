import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickActionsSection extends StatelessWidget {
  final Future<void> Function(String)? onCardTap;

  const QuickActionsSection({super.key, this.onCardTap});

  final List<Map<String, dynamic>> _actions = const [
    {
      'icon': Icons.restaurant_menu,
      'title': 'Diet Plan',
      'subtitle': 'Track your macros',
      'key': 'diet',
      'color': Color(0xFF00E5FF),
    },

    {
      'icon': Icons.fitness_center,
      'title': 'Workout',
      'subtitle': 'Training plans',
      'key': 'workout',
      'color': Color(0xFFFF6B35),
    },

    {
      'icon': Icons.calculate,
      'title': 'Health Calculator',
      'subtitle': 'BMI & nutrition',
      'key': 'calculator',
      'color': Color(0xFF00E5FF),
    },

    {
      'icon': Icons.qr_code_scanner,
      'title': 'Scan Food',
      'subtitle': 'Barcode scanner',
      'key': 'scanner',
      'color': Color(0xFF8338EC),
    },

    {
      'icon': Icons.fastfood,
      'title': 'My Foods',
      'subtitle': 'Manage items',
      'key': 'food',
      'color': Color(0xFFFB5607),
    },

    {
      'icon': Icons.history,
      'title': 'History',
      'subtitle': 'Diet & workouts',
      'key': 'history',
      'color': Color(0xFF06D6A0),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
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
              title: item['title'],
              subtitle: item['subtitle'],
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
                color: color.withOpacity(0.15),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
