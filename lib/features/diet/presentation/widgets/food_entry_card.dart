import 'package:fitness_app/core/l10n/profile_labels.dart';
import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FoodEntryCard extends StatelessWidget {
  final MealEntity entry;
  final int index;

  final VoidCallback? onDelete;
  final Function(String)? onMealNameChanged;
  final VoidCallback? onQuantityTap;

  final List<String> mealOptions;

  const FoodEntryCard({
    super.key,
    required this.entry,
    required this.index,
    required this.mealOptions,
    this.onDelete,
    this.onMealNameChanged,
    this.onQuantityTap,
  });

  @override
  Widget build(BuildContext context) {
    //     String formatTime(
    //   DateTime time,
    // ) {

    //   final hour =
    //       time.hour > 12
    //           ? time.hour - 12
    //           : time.hour;

    //   final minute =
    //       time.minute
    //           .toString()
    //           .padLeft(2, '0');

    //   final period =
    //       time.hour >= 12
    //           ? 'PM'
    //           : 'AM';

    //   return '$hour:$minute $period';
    // }

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(
                      Icons.drag_handle,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      mealLabel(context.l10n, entry.name),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                children: [
                  PopupMenuButton<String>(
                    onSelected: onMealNameChanged,
                    color: Colors.black,
                    itemBuilder: (context) => mealOptions
                        .map(
                          (e) => PopupMenuItem(
                            value: e,
                            child: Text(
                              mealLabel(context.l10n, e),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    child: _chip(
                      mealLabel(context.l10n, entry.name),
                      Colors.green,
                    ),
                  ),
                  // PopupMenuButton<String>(
                  //   onSelected: onAlarmAction,
                  //   color: Colors.black,
                  //   itemBuilder: (context) => [
                  //     const PopupMenuItem(
                  //       value: "set",
                  //       child: Text("Set Alarm",
                  //           style: TextStyle(color: Colors.white)),
                  //     ),
                  //     const PopupMenuItem(
                  //       value: "clear",
                  //       child: Text("Remove Alarm",
                  //           style: TextStyle(color: Colors.red)),
                  //     ),
                  //   ],
                  //   child: _chip(
                  //     entry.alarmTime != null
                  //         ? formatTime(entry.alarmTime!)
                  //         : "Set Alarm",
                  //     Colors.orange,
                  //   ),
                  // ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _macro(context.l10n.macroCalShort, entry.calories),
                  _macro(context.l10n.macroCarbShort, entry.carbs),
                  _macro(context.l10n.macroProtShort, entry.protein),
                  _macro(context.l10n.macroFat, entry.fat),
                ],
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: onQuantityTap,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.cyanAccent),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "${entry.quantity.toStringAsFixed(0)} "
                    "${foodUnitLabel(context.l10n, entry.unit)}",
                    style: const TextStyle(color: Colors.cyanAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12.sp),
      ),
    );
  }

  Widget _macro(String label, num value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white60, fontSize: 10.sp),
          ),
          Text(
            "$value",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
