import 'package:fitness_app/core/models/history_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_header.dart';

class HistoryListPage extends StatelessWidget {
  final String title;

  final List<HistoryItem> items;

  final VoidCallback? onEmptyTap;

  final Function(HistoryItem)? onItemTap;

  const HistoryListPage({
    super.key,

    required this.title,

    required this.items,

    this.onEmptyTap,

    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B0B0B),

      appBar: AppHeader(title: title),

      body: items.isEmpty
          ? _EmptyState(onTap: onEmptyTap)
          : ListView.separated(
              padding: EdgeInsets.all(16.w),

              itemCount: items.length,

              separatorBuilder: (_, __) => SizedBox(height: 12.h),

              itemBuilder: (context, index) {
                final item = items[index];

                return _HistoryCard(
                  item: item,

                  onTap: () {
                    onItemTap?.call(item);
                  },
                );
              },
            ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;

  final VoidCallback? onTap;

  const _HistoryCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(18.r),

      child: Container(
        padding: EdgeInsets.all(16.w),

        decoration: BoxDecoration(
          color: Colors.black,

          borderRadius: BorderRadius.circular(18.r),

          border: Border.all(color: Colors.white10),
        ),

        child: Row(
          children: [
            Container(
              width: 52.w,

              height: 52.w,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: item.completed
                    ? Colors.green.withOpacity(0.15)
                    : Colors.orange.withOpacity(0.15),
              ),

              child: Icon(
                item.completed ? Icons.check : Icons.history,

                color: item.completed ? Colors.green : Colors.orange,
              ),
            ),

            SizedBox(width: 14.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    item.title,

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: 16.sp,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    item.subtitle,

                    style: TextStyle(color: Colors.white60, fontSize: 12.sp),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                Text(
                  item.value,

                  style: TextStyle(
                    color: Colors.white,

                    fontWeight: FontWeight.bold,

                    fontSize: 14.sp,
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  "${item.date.day}/${item.date.month}/${item.date.year}",

                  style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onTap;

  const _EmptyState({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(Icons.history, size: 80.sp, color: Colors.white24),

          SizedBox(height: 12.h),

          Text(
            "No History Yet",

            style: TextStyle(
              color: Colors.white,

              fontSize: 18.sp,

              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            "Complete workouts or diets to see history",

            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
