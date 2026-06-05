import 'package:fitness_app/features/food_item/presentation/bloc/food_item_bloc.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_event.dart';
import 'package:fitness_app/features/food_scanner/domain/entities/scanned_food_entity.dart'
    as scanned;
import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

Future<void> showProductBottomSheet(
  BuildContext context,
  scanned.FoodItemEntity product,
) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF111111),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
    builder: (_) {
      return Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.network(
                  product.imageUrl!,
                  height: 120.h,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 18.h),
            Text(
              product.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            if (product.brand != null)
              Text(
                product.brand!,
                style: TextStyle(color: Colors.white54, fontSize: 13.sp),
              ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _macroItem(
                  "Calories",
                  "${product.calories.toInt()}",
                  Colors.orangeAccent,
                ),
                _macroItem(
                  "Protein",
                  "${product.protein.toInt()}g",
                  Colors.greenAccent,
                ),
                _macroItem(
                  "Carbs",
                  "${product.carbs.toInt()}g",
                  Colors.blueAccent,
                ),
                _macroItem("Fat", "${product.fat.toInt()}g", Colors.pinkAccent),
              ],
            ),
            SizedBox(height: 28.h),
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: () {
                  final food = FoodItemEntity(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),

                    name: product.name,

                    brand: product.brand,

                    imageUrl: product.imageUrl,

                    calories: product.calories,

                    protein: product.protein,

                    carbs: product.carbs,

                    fat: product.fat,

                    barcode: product.barcode,

                    source: "barcode",

                    createdAt: DateTime.now(),
                  );

                  context.read<FoodItemsBloc>().add(SaveFoodItems(food));

                  context.pop();
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
                child: Text(
                  "Add Food Item",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      );
    },
  );
}

Widget _macroItem(String title, String value, Color color) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 4.h),
      Text(
        title,
        style: TextStyle(color: Colors.white54, fontSize: 11.sp),
      ),
    ],
  );
}
