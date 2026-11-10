import '../entities/weekly_report.dart';
import '../repositories/weekly_report_repository.dart';

class GetWeeklyReport {
  GetWeeklyReport(this._repo);
  final WeeklyReportRepository _repo;

  Future<WeeklyReport> call(WeekRange week) => _repo.getReport(week);
}
