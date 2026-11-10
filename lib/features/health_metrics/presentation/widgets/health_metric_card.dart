import 'package:fitness_app/core/di/injection_container.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/health_metrics/domain/entities/health_metrics_entity.dart';
import 'package:fitness_app/features/health_metrics/presentation/bloc/health_metric_bloc.dart';
import 'package:fitness_app/features/health_metrics/presentation/bloc/health_metric_event.dart';
import 'package:fitness_app/features/health_metrics/presentation/bloc/health_metric_state.dart';
import 'package:fitness_app/features/health_metrics/presentation/pages/health_metrics_chart.dart';
import 'package:fitness_app/features/health_metrics/presentation/widgets/add_metric_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A self-loading 7-day chart for one [MetricType]. Each card owns its own
/// [HealthMetricsBloc].
class HealthMetricCard extends StatelessWidget {
  const HealthMetricCard({
    super.key,
    required this.type,
    required this.title,
    required this.color,
  });

  final MetricType type;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HealthMetricsBloc>()..add(LoadHealthMetrics(type)),
      child: BlocBuilder<HealthMetricsBloc, HealthMetricState>(
        builder: (context, state) {
          if (state is HealthMetricLoading) {
            return const AppLoader();
          }

          if (state is HealthMetricError) {
            return SizedBox(
              width: 340.w,
              height: 220.h,
              child: Center(child: Text(state.message)),
            );
          }

          if (state is HealthMetricLoaded) {
            return SizedBox(
              width: 340.w,
              child: HealthMetricsChart(
                chartType: type,
                title: title,
                subtitle: "Last 7 days",
                metrics: state.metrics,
                color: color,
                onAddTap: () {
                  final bloc = context.read<HealthMetricsBloc>();

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) {
                      return BlocProvider.value(
                        value: bloc,
                        child: AddMetricBottomSheet(type: type),
                      );
                    },
                  );
                },
                onRetry: () {
                  context.read<HealthMetricsBloc>().add(
                    LoadHealthMetrics(type),
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
