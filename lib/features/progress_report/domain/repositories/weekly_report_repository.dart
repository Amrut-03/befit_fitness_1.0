import '../entities/weekly_report.dart';

abstract class WeeklyReportRepository {
  Future<WeeklyReport> getReport(WeekRange week);
}
