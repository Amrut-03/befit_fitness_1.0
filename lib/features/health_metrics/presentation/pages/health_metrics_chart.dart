import 'package:fitness_app/features/health_metrics/domain/entities/health_metrics_entity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HealthMetricsChart extends StatefulWidget {
  final MetricType chartType;

  final String title;

  final String subtitle;

  final List<HealthMetricEntity> metrics;

  final Color color;

  final VoidCallback? onRetry;

  final VoidCallback? onAddTap;

  const HealthMetricsChart({
    super.key,
    required this.chartType,
    required this.title,
    required this.subtitle,
    required this.metrics,
    required this.color,
    this.onRetry,
    this.onAddTap,
  });

  @override
  State<HealthMetricsChart> createState() => _HealthMetricsChartState();
}

class _HealthMetricsChartState extends State<HealthMetricsChart> {
  bool _isWeekly = true;

  @override
  Widget build(BuildContext context) {
    if (widget.metrics.isEmpty) {
      return _emptyState();
    }

    return Container(
      padding: EdgeInsets.all(16.w),

      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20.r),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _header(),

          SizedBox(height: 16.h),

          _chart(),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            color: widget.color.withOpacity(0.15),
          ),

          child: Icon(_getIcon(), color: widget.color, size: 18.sp),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                widget.subtitle,

                style: TextStyle(
                  fontSize: 11.sp,

                  color: Colors.white.withOpacity(0.5),
                ),
              ),

              SizedBox(height: 2.h),

              Text(
                widget.title,

                style: TextStyle(
                  fontSize: 17.sp,

                  fontWeight: FontWeight.bold,

                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        _actionWidget(),
      ],
    );
  }

  IconData _getIcon() {
    switch (widget.chartType) {
      case MetricType.weight:
        return Icons.monitor_weight;

      case MetricType.heartRate:
        return Icons.favorite;

      case MetricType.sleep:
        return Icons.bed;
    }
  }

  Widget _actionWidget() {
    if (widget.onAddTap != null) {
      return GestureDetector(
        onTap: widget.onAddTap,

        child: Container(
          padding: EdgeInsets.all(8.w),

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            color: widget.color.withOpacity(0.15),
          ),

          child: Icon(Icons.add, color: widget.color),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),

        borderRadius: BorderRadius.circular(20.r),
      ),

      child: Row(children: [_toggle("W", true), _toggle("M", false)]),
    );
  }

  Widget _toggle(String label, bool isWeek) {
    final isSelected = _isWeekly == isWeek;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isWeekly = isWeek;
        });
      },

      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),

        decoration: BoxDecoration(
          color: isSelected
              ? widget.color.withOpacity(0.2)
              : Colors.transparent,

          borderRadius: BorderRadius.circular(20.r),
        ),

        child: Text(
          label,

          style: TextStyle(
            fontSize: 11.sp,

            fontWeight: FontWeight.bold,

            color: isSelected ? widget.color : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _chart() {
    final filteredMetrics =
        (_isWeekly
                ? widget.metrics.reversed.take(7).toList().reversed.toList()
                : widget.metrics)
            .where((e) => e.value.isFinite)
            .toList();

    final spots = filteredMetrics
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    if (filteredMetrics.isEmpty) {
      return _emptyState();
    }

    return SizedBox(
      height: 200.h,

      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            drawVerticalLine: false,

            getDrawingHorizontalLine: (value) =>
                FlLine(color: widget.color.withOpacity(0.1), strokeWidth: 1),
          ),

          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,

                reservedSize: 40,

                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),

                    style: TextStyle(
                      fontSize: 10.sp,

                      color: Colors.white.withOpacity(0.5),
                    ),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,

                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index >= 0 && index < filteredMetrics.length) {
                    final date = filteredMetrics[index].date;

                    return Text(
                      "${date.day}/${date.month}",

                      style: TextStyle(
                        fontSize: 10.sp,

                        color: Colors.white.withOpacity(0.5),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),

          borderData: FlBorderData(
            border: Border.all(color: widget.color.withOpacity(0.15)),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: spots,

              isCurved: true,

              color: widget.color,

              barWidth: 3,

              dotData: const FlDotData(show: false),

              belowBarData: BarAreaData(
                show: true,

                color: widget.color.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: 340.w,

      padding: EdgeInsets.all(20.w),

      decoration: BoxDecoration(
        color: Colors.black,

        borderRadius: BorderRadius.circular(20.r),

        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// HEADER
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: widget.color.withOpacity(0.15),
                ),

                child: Icon(_getIcon(), color: widget.color, size: 18.sp),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      widget.subtitle,

                      style: TextStyle(
                        fontSize: 11.sp,

                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      widget.title,

                      style: TextStyle(
                        fontSize: 17.sp,

                        fontWeight: FontWeight.bold,

                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              _actionWidget(),
            ],
          ),

          SizedBox(height: 30.h),

          Center(
            child: Column(
              children: [
                Icon(
                  _getIcon(),

                  color: Colors.white.withOpacity(0.5),

                  size: 40.sp,
                ),

                SizedBox(height: 10.h),

                Text(
                  "No data yet",

                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                ),

                SizedBox(height: 4.h),

                Text(
                  "Sync Google Fit or add manually",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),

                    fontSize: 11.sp,
                  ),
                ),

                if (widget.onRetry != null) ...[
                  SizedBox(height: 14.h),

                  ElevatedButton(
                    onPressed: widget.onRetry,

                    child: const Text("Retry"),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
