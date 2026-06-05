import 'package:fitness_app/core/models/history_detail_data.dart';
import 'package:fitness_app/core/models/history_item.dart';
import 'package:fitness_app/core/widgets/showHistoryDetailBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fitness_app/core/widgets/history_page.dart';

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

            subtitle:
                "${history.protein.toInt()}g Protein • "
                "${history.carbs.toInt()}g Carbs • "
                "${history.fat.toInt()}g Fat",

            value: "${history.calories.toInt()} kcal",

            date: history.completedAt,

            completed: true,
          );
        }).toList();

        return HistoryListPage(
          title: "Diet History",

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
                  "Calories": "${history.calories.toInt()} kcal",

                  "Protein": "${history.protein.toInt()} g",

                  "Carbs": "${history.carbs.toInt()} g",

                  "Fat": "${history.fat.toInt()} g",
                },
              ),
            );
          },
        );
      },
    );
  }
}
