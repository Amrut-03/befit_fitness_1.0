import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

void showAddFoodItemsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _AddFoodItemsSheet(),
  );
}

class _AddFoodItemsSheet extends StatelessWidget {
  const _AddFoodItemsSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Add Food Item",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Choose how you want to add food",
              style: TextStyle(color: Colors.white54, fontSize: 13.sp),
            ),
            SizedBox(height: 28.h),
            _OptionCard(
              icon: Icons.qr_code_scanner_rounded,
              title: "Scan Barcode",
              subtitle: "Quickly scan packaged food items",
              color: const Color(0xFF00E5FF),
              onTap: () {
                Navigator.pop(context);
                context.push('/barcode-food-entry');
              },
            ),
            SizedBox(height: 16.h),
            _OptionCard(
              icon: Icons.edit_note_rounded,
              title: "Add Manually",
              subtitle: "Create your own custom food item",
              color: Colors.greenAccent,
              onTap: () {
                Navigator.pop(context);
                context.push('/manual-food-entry');
              },
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12.sp,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white38,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
