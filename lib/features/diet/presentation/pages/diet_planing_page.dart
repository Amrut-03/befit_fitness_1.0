import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_event.dart';
import 'package:fitness_app/features/diet/presentation/widgets/edit_quantity_bottom_sheet.dart';
import 'package:fitness_app/features/diet/presentation/widgets/select_food_bottom_sheet.dart';
import 'package:fitness_app/features/diet/presentation/widgets/diet_plan_header_section.dart';
import 'package:fitness_app/features/diet/presentation/widgets/food_entry_list.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PlanDietPage extends StatefulWidget {
  final DietPlanEntity? existingPlan;

  const PlanDietPage({super.key, this.existingPlan});

  @override
  State<PlanDietPage> createState() => _PlanDietPageState();
}

class _PlanDietPageState extends State<PlanDietPage> {
  final TextEditingController _nameController = TextEditingController();
  List<MealEntity> meals = [];
  bool _isMacroSectionExpanded = true;
  double get consumedCalories => meals.fold(0, (sum, m) => sum + m.calories);

  double get consumedCarbs => meals.fold(0, (sum, m) => sum + m.carbs);

  double get consumedProtein => meals.fold(0, (sum, m) => sum + m.protein);

  double get consumedFat => meals.fold(0, (sum, m) => sum + m.fat);

  final List<String> _mealNameOptions = [
    "Breakfast",
    "Lunch",
    "Dinner",
    "Snack",
  ];

  @override
  void initState() {
    super.initState();

    context.read<DietBloc>()..add(LoadDietPlans());

    if (widget.existingPlan != null) {
      _nameController.text = widget.existingPlan!.name;

      meals = List.from(widget.existingPlan!.meals);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppHeader(
        title: "Plan Your Diet",
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Color(0xFF00E5FF)),
            onPressed: () {
              if (_nameController.text.trim().isEmpty) {
                return;
              }

              final plan = DietPlanEntity(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text.trim(),
                meals: meals,
                activeDate: null,
              );

              context.read<DietBloc>().add(SaveDietPlanEvent(plan));

              context.pop();
            },
            tooltip: 'Save Diet Plan',
          ),
        ],
      ),
      body: Column(
        children: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is! ProfileLoaded) {
                return const SizedBox();
              }

              final profile = state.profile;

              return DietPlanHeaderSection(
                controller: _nameController,

                isExpanded: _isMacroSectionExpanded,

                onToggle: () {
                  setState(() {
                    _isMacroSectionExpanded = !_isMacroSectionExpanded;
                  });
                },

                calories: consumedCalories,

                carbs: consumedCarbs,

                protein: consumedProtein,

                fat: consumedFat,

                caloriesGoal: profile.dailyCalorieGoal.toDouble(),

                carbsGoal: profile.carbsGoal.toDouble(),

                proteinGoal: profile.proteinGoal.toDouble(),

                fatGoal: profile.fatGoal.toDouble(),
              );
            },
          ),
          Expanded(
            child:
                // true
                //     ? _buildEmptyState()
                //     :
                ClipRect(
                  child: FoodEntryList(
                    meals: meals,
                    mealOptions: _mealNameOptions,

                    onReorder: (updatedList) {
                      setState(() {
                        meals = updatedList;
                      });
                    },

                    onDelete: (index) {
                      setState(() {
                        meals.removeAt(index);
                      });
                    },

                    onMealNameChanged: (index, value) {},
                    onAlarmAction: (index, value) {},
                    onQuantityTap: (index) {
                      showEditQuantityBottomSheet(
                        context: context,

                        meal: meals[index],

                        onUpdated: (updatedMeal) {
                          setState(() {
                            meals[index] = updatedMeal;
                          });
                        },
                      );
                    },
                  ),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "add_food_button",
        onPressed: () {
          showAddFoodBottomSheet(context, (selectedMeals) {
            setState(() {
              meals.addAll(selectedMeals);
            });
          });
        },
        backgroundColor: Color(0xFF00E5FF),
        icon: Icon(Icons.add, color: Colors.black),
        label: Text(
          'Add Food',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
