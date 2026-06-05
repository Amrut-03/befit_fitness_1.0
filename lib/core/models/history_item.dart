class HistoryItem {
  final String id;

  final String title;

  final String subtitle;

  final String value;

  final DateTime date;

  final bool completed;

  const HistoryItem({
    required this.id,

    required this.title,

    required this.subtitle,

    required this.value,

    required this.date,

    required this.completed,
  });
}
