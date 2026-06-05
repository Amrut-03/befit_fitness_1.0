import 'package:fitness_app/core/models/history_detail_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showHistoryDetailBottomSheet(
  BuildContext context,

  HistoryDetailData data,
) {
  showModalBottomSheet(
    context: context,

    isScrollControlled: true,

    backgroundColor: Colors.transparent,

    builder: (_) {
      return _HistoryDetailBottomSheet(data: data);
    },
  );
}

class _HistoryDetailBottomSheet extends StatelessWidget {
  final HistoryDetailData data;

  const _HistoryDetailBottomSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0B),

        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),

      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                data.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                DateFormat(
                  'dd MMM yyyy • hh:mm a',
                ).format(data.completedAt).toString(),
                style: const TextStyle(color: Colors.white54),
              ),

              const SizedBox(height: 20),

              if (data.stats.isNotEmpty) ...[
                const Text(
                  "Summary",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,

                  runSpacing: 10,

                  children: data.stats.entries.map((e) {
                    return Container(
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: Colors.black,

                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Text(
                            e.key,
                            style: const TextStyle(color: Colors.white60),
                          ),

                          Text(
                            e.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 24),

              if (data.items.isNotEmpty) ...[
                const Text(
                  "Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ...data.items.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),

                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.black,

                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            item,

                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
