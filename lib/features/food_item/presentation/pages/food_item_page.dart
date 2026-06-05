import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_bloc.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_event.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_state.dart';
import 'package:fitness_app/features/food_item/presentation/widgets/add_food_items_bottom_sheet.dart';
import 'package:fitness_app/features/food_item/presentation/widgets/empty_food_view.dart';
import 'package:fitness_app/features/food_item/presentation/widgets/food_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FoodItemsPage extends StatefulWidget {
  const FoodItemsPage({super.key});

  @override
  State<FoodItemsPage> createState() => _FoodItemsPageState();
}

class _FoodItemsPageState extends State<FoodItemsPage> {
  @override
  void initState() {
    super.initState();

    context.read<FoodItemsBloc>().add(LoadFoodItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppHeader(title: "My Food Items"),
      body: BlocBuilder<FoodItemsBloc, FoodItemsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const AppLoader();
          }

          if (state.items.isEmpty) {
            return const EmptyFoodView();
          }

          return FoodListView(items: state.items);
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddFoodItemsBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
