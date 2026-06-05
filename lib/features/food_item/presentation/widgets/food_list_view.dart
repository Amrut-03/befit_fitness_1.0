import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_bloc.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_event.dart';
import 'package:fitness_app/features/food_item/presentation/widgets/food_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FoodListView extends StatelessWidget {
  final List<FoodItemEntity> items;

  const FoodListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];

        return FoodItemCard(
          item: item,
          onTap: () {},
          onDelete: () {
            context.read<FoodItemsBloc>().add(DeleteFoodItem(item.id));
          },
        );
      },
    );
  }
}
