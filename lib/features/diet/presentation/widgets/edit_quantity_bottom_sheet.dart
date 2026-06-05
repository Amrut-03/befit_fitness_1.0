import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> showEditQuantityBottomSheet({
  required BuildContext context,
  required MealEntity meal,
  required Function(MealEntity) onUpdated,
}) async {
  final TextEditingController controller = TextEditingController(
    text: meal.quantity.toStringAsFixed(0),
  );

  String selectedUnit = meal.unit;

  final double baseQuantity = meal.quantity == 0 ? 100 : meal.quantity;

  final double baseCalories = meal.calories;

  final double baseProtein = meal.protein;

  final double baseCarbs = meal.carbs;

  final double baseFat = meal.fat;

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF111111),
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final quantity = double.tryParse(controller.text) ?? baseQuantity;

          final factor = quantity / baseQuantity;

          final updatedCalories = baseCalories * factor;

          final updatedProtein = baseProtein * factor;

          final updatedCarbs = baseCarbs * factor;

          final updatedFat = baseFat * factor;

          return Padding(
            padding: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
              top: 24.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                Text(
                  "Edit Quantity",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  meal.name,
                  style: TextStyle(color: Colors.white54, fontSize: 13.sp),
                ),

                SizedBox(height: 28.h),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quantity",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 10.h),

                          TextField(
                            controller: controller,

                            keyboardType: TextInputType.number,

                            style: const TextStyle(color: Colors.white),

                            onChanged: (_) {
                              setModalState(() {});
                            },

                            decoration: InputDecoration(
                              filled: true,

                              fillColor: Colors.white.withOpacity(0.05),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.r),

                                borderSide: BorderSide.none,
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.r),

                                borderSide: const BorderSide(
                                  color: Color(0xFF00E5FF),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 16.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Unit",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 10.h),

                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w),

                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),

                              borderRadius: BorderRadius.circular(18.r),
                            ),

                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedUnit,

                                dropdownColor: Colors.black,

                                style: const TextStyle(color: Colors.white),

                                items: ['g', 'ml', 'piece', 'slice', 'cup'].map(
                                  (unit) {
                                    return DropdownMenuItem(
                                      value: unit,

                                      child: Text(unit),
                                    );
                                  },
                                ).toList(),

                                onChanged: (value) {
                                  setModalState(() {
                                    selectedUnit = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 28.h),

                Container(
                  padding: EdgeInsets.all(18.w),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.r),

                    color: Colors.white.withOpacity(0.04),

                    border: Border.all(color: Colors.white10),
                  ),

                  child: Column(
                    children: [
                      _macroRow(
                        "Calories",
                        "${updatedCalories.toStringAsFixed(1)} kcal",
                        Colors.orangeAccent,
                      ),

                      SizedBox(height: 14.h),

                      _macroRow(
                        "Protein",
                        "${updatedProtein.toStringAsFixed(1)} g",
                        Colors.greenAccent,
                      ),

                      SizedBox(height: 14.h),

                      _macroRow(
                        "Carbs",
                        "${updatedCarbs.toStringAsFixed(1)} g",
                        Colors.blueAccent,
                      ),

                      SizedBox(height: 14.h),

                      _macroRow(
                        "Fat",
                        "${updatedFat.toStringAsFixed(1)} g",
                        Colors.pinkAccent,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () {
                      final updatedMeal = meal.copyWith(
                        quantity: quantity,

                        unit: selectedUnit,

                        calories: updatedCalories,

                        protein: updatedProtein,

                        carbs: updatedCarbs,

                        fat: updatedFat,
                      );

                      onUpdated(updatedMeal);

                      Navigator.pop(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),

                    child: Text(
                      "Update Quantity",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _macroRow(String label, String value, Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(color: Colors.white70, fontSize: 14.sp),
      ),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
