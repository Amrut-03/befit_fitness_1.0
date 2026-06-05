import 'package:fitness_app/features/health_metrics/domain/entities/health_metrics_entity.dart';
import 'package:fitness_app/features/health_metrics/presentation/bloc/health_metric_bloc.dart';
import 'package:fitness_app/features/health_metrics/presentation/bloc/health_metric_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddMetricBottomSheet extends StatefulWidget {
  final MetricType type;

  const AddMetricBottomSheet({super.key, required this.type});

  @override
  State<AddMetricBottomSheet> createState() => _AddMetricBottomSheetState();
}

class _AddMetricBottomSheetState extends State<AddMetricBottomSheet> {
  final TextEditingController controller = TextEditingController();

  DateTime selectedDate = DateTime.now();

  String get title {
    switch (widget.type) {
      case MetricType.weight:
        return "Add Weight";

      case MetricType.heartRate:
        return "Add Heart Rate";

      case MetricType.sleep:
        return "Add Sleep";
    }
  }

  String get unit {
    switch (widget.type) {
      case MetricType.weight:
        return "KG";

      case MetricType.heartRate:
        return "BPM";

      case MetricType.sleep:
        return "Hours";
    }
  }

  IconData get icon {
    switch (widget.type) {
      case MetricType.weight:
        return Icons.monitor_weight;

      case MetricType.heartRate:
        return Icons.favorite;

      case MetricType.sleep:
        return Icons.bed;
    }
  }

  Color get color {
    switch (widget.type) {
      case MetricType.weight:
        return const Color(0xFF00E5FF);

      case MetricType.heartRate:
        return const Color(0xFFFF006E);

      case MetricType.sleep:
        return const Color(0xFF5B8CFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),

      decoration: BoxDecoration(
        color: const Color(0xFF111111),

        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),

          topRight: Radius.circular(24.r),
        ),
      ),

      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 50.w,

              height: 4.h,

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),

                borderRadius: BorderRadius.circular(100.r),
              ),
            ),

            SizedBox(height: 24.h),

            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),

                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),

                    shape: BoxShape.circle,
                  ),

                  child: Icon(icon, color: color),
                ),

                SizedBox(width: 12.w),

                Text(
                  title,

                  style: TextStyle(
                    fontSize: 20.sp,

                    fontWeight: FontWeight.bold,

                    color: Colors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            TextField(
              controller: controller,

              keyboardType: TextInputType.number,

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: "Enter $unit",

                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),

                suffixText: unit,

                suffixStyle: TextStyle(color: color),

                filled: true,

                fillColor: Colors.white.withOpacity(0.05),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,

                  initialDate: selectedDate,

                  firstDate: DateTime(2020),

                  lastDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },

              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),

                  borderRadius: BorderRadius.circular(16.r),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white),

                    SizedBox(width: 12.w),

                    Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",

                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,

                  padding: EdgeInsets.symmetric(vertical: 16.h),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),

                onPressed: () {
                  final value = double.tryParse(controller.text);

                  if (value == null) {
                    return;
                  }

                  final metric = HealthMetricEntity(
                    type: widget.type,

                    date: selectedDate,

                    value: value,

                    isManual: true,
                  );

                  context.read<HealthMetricsBloc>().add(
                    SaveHealthMetricEvent(metric),
                  );

                  Navigator.pop(context);
                },

                child: Text(
                  "Save",

                  style: TextStyle(
                    fontSize: 16.sp,

                    fontWeight: FontWeight.bold,

                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
