import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/weekly_report.dart';
import '../../domain/usecases/get_weekly_report.dart';

sealed class WeeklyReportEvent extends Equatable {
  const WeeklyReportEvent();

  @override
  List<Object?> get props => [];
}

/// Shows the week [offset] weeks back from this one (0 = this week).
class WeeklyReportRequested extends WeeklyReportEvent {
  const WeeklyReportRequested([this.offset = 0]);
  final int offset;

  @override
  List<Object?> get props => [offset];
}

/// Reloads the shown week (pull to refresh, app resumed).
class WeeklyReportRefreshed extends WeeklyReportEvent {
  const WeeklyReportRefreshed();
}

enum ReportStatus { initial, loading, ready, failure }

class WeeklyReportState extends Equatable {
  const WeeklyReportState({
    this.status = ReportStatus.initial,
    this.offset = 0,
    this.report,
    this.message,
  });

  final ReportStatus status;

  /// Weeks back from this one.
  final int offset;
  final WeeklyReport? report;
  final String? message;

  @override
  List<Object?> get props => [status, offset, report, message];
}

class WeeklyReportBloc extends Bloc<WeeklyReportEvent, WeeklyReportState> {
  WeeklyReportBloc({
    required GetWeeklyReport getWeeklyReport,
    DateTime Function()? clock,
  }) : _get = getWeeklyReport,
       _now = clock ?? DateTime.now,
       super(const WeeklyReportState()) {
    on<WeeklyReportRequested>((e, emit) => _load(emit, e.offset, cached: true));
    on<WeeklyReportRefreshed>(
      (e, emit) => _load(emit, state.offset, cached: false),
    );
  }

  /// How far back the user can page.
  static const maxWeeksBack = 12;

  final GetWeeklyReport _get;
  final DateTime Function() _now;
  final _cache = <DateTime, WeeklyReport>{};

  Future<void> _load(
    Emitter<WeeklyReportState> emit,
    int offset, {
    required bool cached,
  }) async {
    final o = offset.clamp(0, maxWeeksBack);
    final week = WeekRange.of(_now()).shift(-o);

    final hit = _cache[week.start];
    if (cached && hit != null) {
      emit(
        WeeklyReportState(status: ReportStatus.ready, offset: o, report: hit),
      );
      return;
    }

    emit(
      WeeklyReportState(
        status: ReportStatus.loading,
        offset: o,
        // Keep showing the current report while refreshing the same week.
        report: state.report?.week == week ? state.report : null,
      ),
    );
    try {
      final report = await _get(week);
      _cache[week.start] = report;
      emit(
        WeeklyReportState(
          status: ReportStatus.ready,
          offset: o,
          report: report,
        ),
      );
    } catch (e) {
      emit(
        WeeklyReportState(
          status: ReportStatus.failure,
          offset: o,
          report: state.report,
          message: Failure.fromException(e).message,
        ),
      );
    }
  }
}
