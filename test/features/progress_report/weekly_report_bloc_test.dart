import 'package:fitness_app/features/progress_report/domain/entities/weekly_report.dart';
import 'package:fitness_app/features/progress_report/domain/usecases/get_weekly_report.dart';
import 'package:fitness_app/features/progress_report/presentation/bloc/weekly_report_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Get extends Mock implements GetWeeklyReport {}

void main() {
  final now = DateTime(2026, 11, 12);
  final thisWeek = WeekRange.of(now);
  late _Get get;

  setUpAll(() => registerFallbackValue(thisWeek));

  setUp(() {
    get = _Get();
    when(() => get(any())).thenAnswer(
      (i) async => WeeklyReport(
        week: i.positionalArguments.first as WeekRange,
        daysElapsed: 7,
      ),
    );
  });

  WeeklyReportBloc build() =>
      WeeklyReportBloc(getWeeklyReport: get, clock: () => now);

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('loads this week, then pages back and caches', () async {
    final bloc = build()..add(const WeeklyReportRequested());
    await settle();
    expect(bloc.state.status, ReportStatus.ready);
    expect(bloc.state.report!.week, thisWeek);

    bloc.add(const WeeklyReportRequested(1));
    await settle();
    expect(bloc.state.offset, 1);
    expect(bloc.state.report!.week, thisWeek.shift(-1));

    bloc.add(const WeeklyReportRequested());
    await settle();
    verify(() => get(thisWeek)).called(1); // second visit from cache
    await bloc.close();
  });

  test('refresh bypasses the cache', () async {
    final bloc = build()..add(const WeeklyReportRequested());
    await settle();
    bloc.add(const WeeklyReportRefreshed());
    await settle();
    verify(() => get(thisWeek)).called(2);
    await bloc.close();
  });

  test('offset is clamped to 0..maxWeeksBack', () async {
    final bloc = build()..add(const WeeklyReportRequested(99));
    await settle();
    expect(bloc.state.offset, WeeklyReportBloc.maxWeeksBack);
    bloc.add(const WeeklyReportRequested(-3));
    await settle();
    expect(bloc.state.offset, 0);
    await bloc.close();
  });

  test('a failure keeps the previous report and reports a message', () async {
    final bloc = build()..add(const WeeklyReportRequested());
    await settle();
    when(() => get(any())).thenThrow(Exception('x'));

    bloc.add(const WeeklyReportRefreshed());
    await settle();

    expect(bloc.state.status, ReportStatus.failure);
    expect(bloc.state.report, isNotNull);
    expect(bloc.state.message, isNotNull);
    await bloc.close();
  });
}
