class HistoryDetailData {
  final String title;

  final DateTime completedAt;

  final List<String> items;

  final Map<String, String> stats;

  const HistoryDetailData({
    required this.title,

    required this.completedAt,

    required this.items,

    required this.stats,
  });
}
