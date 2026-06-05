import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItemEntity item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const FoodItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: () => context.push("/manual-food-entry", extra: item),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.r),
          gradient: LinearGradient(
            colors: [const Color(0xFF1A1A1A), const Color(0xFF111111)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 62.w,
              width: 62.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00E5FF).withOpacity(0.25),
                    const Color(0xFF00C2FF).withOpacity(0.15),
                  ],
                ),
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: const Color(0xFF00E5FF),
                size: 28.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  if (item.brand != null)
                    Text(
                      item.brand!,
                      style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                    ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withOpacity(0.12),

                      borderRadius: BorderRadius.circular(30.r),
                    ),

                    child: Text(
                      "Per ${item.quantity?.toStringAsFixed(0)} ${item.unit}",

                      style: TextStyle(
                        color: const Color(0xFF00E5FF),

                        fontSize: 11.sp,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _macroChip(
                        label: "${item.calories?.toInt() ?? 0} kcal",
                        color: Colors.orangeAccent,
                      ),
                      _macroChip(
                        label: "P ${item.protein?.toInt() ?? 0}",
                        color: Colors.greenAccent,
                      ),
                      _macroChip(
                        label: "C ${item.carbs?.toInt() ?? 0}",
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: item.source == "Manual"
                        ? Colors.green.withOpacity(0.15)
                        : Colors.deepPurple.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    item.source == "Manual" ? "Manual" : "Scanned",
                    style: TextStyle(
                      color: item.source == "Manual"
                          ? Colors.greenAccent
                          : Colors.deepPurpleAccent,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 20.sp,
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

  Widget _macroChip({required String label, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
