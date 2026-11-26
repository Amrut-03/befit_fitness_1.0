import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/models/history_detail_data.dart';
import 'package:fitness_app/core/models/history_item.dart';
import 'package:fitness_app/core/widgets/history_page.dart';
import 'package:fitness_app/core/widgets/show_history_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/diet_bloc.dart';
import '../bloc/diet_event.dart';
import '../bloc/diet_state.dart';

class DietHistoryPage extends StatefulWidget {
  const DietHistoryPage({super.key});

  @override
  State<DietHistoryPage> createState() => _DietHistoryPageState();
}

class _DietHistoryPageState extends State<DietHistoryPage> {
  @override
  void initState() {
    super.initState();

    context.read<DietBloc>().add(LoadDietHistory());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DietBloc, DietState>(
      builder: (context, state) {
        final items = state.history.map((history) {
          return HistoryItem(
            id: history.id,

            title: history.planName,

            subtitle: context.l10n.macroSummary(
              history.protein.toInt(),
              history.carbs.toInt(),
              history.fat.toInt(),
            ),

            value: context.l10n.unitKcal(history.calories.toInt().toString()),

            date: history.completedAt,

            completed: true,
          );
        }).toList();

        return HistoryListPage(
          title: context.l10n.historyDietTitle,

          items: items,

          onItemTap: (item) {
            final history = state.history.firstWhere((e) => e.id == item.id);

            showHistoryDetailBottomSheet(
              context,

              HistoryDetailData(
                title: history.planName,

                completedAt: history.completedAt,

                items: history.meals,

                stats: {
                  context.l10n.statCalories: context.l10n.unitKcal(
                    history.calories.toInt().toString(),
                  ),
                  context.l10n.macroProtein: context.l10n.unitGrams(
                    history.protein.toInt().toString(),
                  ),
                  context.l10n.macroCarbs: context.l10n.unitGrams(
                    history.carbs.toInt().toString(),
                  ),
                  context.l10n.macroFat: context.l10n.unitGrams(
                    history.fat.toInt().toString(),
                  ),
                },
              ),
            );
          },
        );
      },
    );
  }
}
