import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModernMacrosWidget extends StatelessWidget {
  final double carbs;
  final double protein;
  final double fat;
  final VoidCallback? onInfoTap;

  const ModernMacrosWidget({
    super.key,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final carbsClamped = carbs.clamp(0.0, 100.0).toDouble();
    final proteinClamped = protein.clamp(0.0, 100.0).toDouble();
    final fatClamped = fat.clamp(0.0, 100.0).toDouble();

    final overall = ((carbsClamped + proteinClamped + fatClamped) / 3);

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.restaurant, color: Colors.white, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Macros",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Today’s nutrition balance",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              if (onInfoTap != null)
                GestureDetector(
                  onTap: onInfoTap,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 30.h),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 140.w,
                  width: 140.w,
                  child: CircularProgressIndicator(
                    value: carbsClamped / 100,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation(Color(0xFFFF006E)),
                  ),
                ),
                SizedBox(
                  height: 110.w,
                  width: 110.w,
                  child: CircularProgressIndicator(
                    value: proteinClamped / 100,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation(Color(0xFFFF6B35)),
                  ),
                ),
                SizedBox(
                  height: 80.w,
                  width: 80.w,
                  child: CircularProgressIndicator(
                    value: fatClamped / 100,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation(Color(0xFF00E5FF)),
                  ),
                ),
                Text(
                  "${overall.toStringAsFixed(0)}%",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Row(
              children: [
                Expanded(
                  flex: carbsClamped.toInt(),
                  child: Container(height: 6.h, color: Color(0xFFFF006E)),
                ),
                Expanded(
                  flex: proteinClamped.toInt(),
                  child: Container(height: 6.h, color: Color(0xFFFF6B35)),
                ),
                Expanded(
                  flex: fatClamped.toInt(),
                  child: Container(height: 6.h, color: Color(0xFF00E5FF)),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _macroCard("Carbs", carbsClamped, Color(0xFFFF006E)),
              _macroCard("Protein", proteinClamped, Color(0xFFFF6B35)),
              _macroCard("Fat", fatClamped, Color(0xFF00E5FF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroCard(String label, double value, Color color) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: Colors.grey.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            "${value.toStringAsFixed(0)}%",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
