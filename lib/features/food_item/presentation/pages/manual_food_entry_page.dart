import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/l10n/profile_labels.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/food_item/presentation/widgets/food_form_fields.dart';
import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_bloc.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ManualFoodEntryPage extends StatefulWidget {
  final FoodItemEntity? item;

  const ManualFoodEntryPage({super.key, this.item});

  @override
  State<ManualFoodEntryPage> createState() => _ManualFoodEntryPageState();
}

class _ManualFoodEntryPageState extends State<ManualFoodEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(
    text: '100',
  );

  String _selectedUnit = 'g';

  @override
  void initState() {
    super.initState();

    if (widget.item != null) {
      _nameController.text = widget.item!.name;

      _brandController.text = widget.item!.brand ?? '';

      _caloriesController.text = widget.item!.calories?.toString() ?? '';

      _proteinController.text = widget.item!.protein?.toString() ?? '';

      _carbsController.text = widget.item!.carbs?.toString() ?? '';

      _fatController.text = widget.item!.fat?.toString() ?? '';

      _quantityController.text = widget.item?.quantity.toString() ?? '100';

      _selectedUnit = widget.item?.unit ?? 'g';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _saveFoodItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final food = FoodItemEntity(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      calories: double.tryParse(_caloriesController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0,
      fat: double.tryParse(_fatController.text) ?? 0,
      source: widget.item?.source ?? "manual",
      barcode: widget.item?.barcode,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
      quantity: double.tryParse(_quantityController.text) ?? 100,
      unit: _selectedUnit,
    );

    if (widget.item != null) {
      context.read<FoodItemsBloc>().add(UpdateFoodItem(food));
    } else {
      context.read<FoodItemsBloc>().add(SaveFoodItems(food));
    }
    context.pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.foodSaved)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppHeader(
        title: widget.item != null
            ? context.l10n.foodEditTitle
            : context.l10n.foodManualTitle,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.20),
                        const Color(0xFF00C2FF).withValues(alpha: 0.10),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          color: AppColors.primary,
                          size: 34.sp,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        context.l10n.foodCreateCustom,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        context.l10n.foodCreateCustomHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28.h),
                _sectionTitle(context.l10n.foodInfoSection),
                SizedBox(height: 14.h),
                FoodTextField(
                  controller: _nameController,
                  label: context.l10n.foodName,
                  hint: context.l10n.foodNameHint,
                  icon: Icons.fastfood_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n.foodNameRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                FoodTextField(
                  controller: _brandController,
                  label: context.l10n.foodBrand,
                  hint: context.l10n.foodBrandHint,
                  icon: Icons.business_rounded,
                ),
                SizedBox(height: 28.h),
                _sectionTitle(context.l10n.foodServingSection),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: FoodTextField(
                        controller: _quantityController,
                        label: context.l10n.foodQuantity,
                        hint: '100',
                        icon: Icons.scale_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          }

                          final parsed = double.tryParse(value);

                          if (parsed == null || parsed <= 0) {
                            return context.l10n.foodPositiveNumber;
                          }

                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.foodUnit,
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
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedUnit,
                                dropdownColor: Colors.black,
                                style: const TextStyle(color: Colors.white),
                                items: ['g', 'ml', 'piece', 'slice', 'cup'].map(
                                  (unit) {
                                    return DropdownMenuItem(
                                      value: unit,
                                      child: Text(
                                        foodUnitLabel(context.l10n, unit),
                                      ),
                                    );
                                  },
                                ).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUnit = value!;
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
                SizedBox(height: 16.h),
                _sectionTitle(context.l10n.foodNutritionSection),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: MacroInputField(
                        controller: _caloriesController,
                        label: context.l10n.statCalories,
                        suffix: 'kcal',
                        color: Colors.orangeAccent,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: MacroInputField(
                        controller: _proteinController,
                        label: context.l10n.macroProtein,
                        suffix: 'g',
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: MacroInputField(
                        controller: _carbsController,
                        label: context.l10n.macroCarbs,
                        suffix: 'g',
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: MacroInputField(
                        controller: _fatController,
                        label: context.l10n.macroFat,
                        suffix: 'g',
                        color: Colors.pinkAccent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _saveFoodItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    child: Text(
                      widget.item != null
                          ? context.l10n.foodUpdate
                          : context.l10n.foodSave,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
