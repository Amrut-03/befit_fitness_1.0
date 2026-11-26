import 'package:fitness_app/core/l10n/profile_labels.dart';
import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/profile/presentation/widgets/profile_text_field.dart';
import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/features/onboarding/domain/utils/goal_calculator.dart';
import 'package:fitness_app/features/onboarding/domain/utils/macros_calculator.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileEntity profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;

  late TextEditingController _weightController;

  late TextEditingController _heightController;

  late TextEditingController _ageController;

  late String goal;

  late String gender;
  final List<String> goals = [
    'Build Muscle',
    'Lose Weight',
    'Stay Fit',
    'Improve Strength',
    'Fitness Goal',
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.profile.name);

    _weightController = TextEditingController(
      text: widget.profile.weight == 0
          ? ''
          : widget.profile.weight.round().toString(),
    );

    _heightController = TextEditingController(
      text: widget.profile.height == 0
          ? ''
          : widget.profile.height.round().toString(),
    );

    _ageController = TextEditingController(
      text: widget.profile.age == 0
          ? ''
          : widget.profile.age.round().toString(),
    );

    goal = goals.contains(widget.profile.goal)
        ? widget.profile.goal
        : goals.first;

    gender = widget.profile.gender;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: context.l10n.profileEdit),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 52.r,
                backgroundColor: AppColors.primary,
                child: Text(
                  _nameController.text.trim().isNotEmpty
                      ? _nameController.text.trim()[0].toUpperCase()
                      : "A",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 38.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.h),
            _label(context.l10n.profileFullName),
            ProfileTextField(
              controller: _nameController,
              hint: context.l10n.profileEnterName,
            ),
            SizedBox(height: 18.h),
            _label(context.l10n.profileGoal),
            _dropdown(),
            SizedBox(height: 18.h),
            _label(context.l10n.profileWeightKg),
            ProfileTextField(
              controller: _weightController,
              hint: context.l10n.profileEnterWeight,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 18.h),
            _label(context.l10n.profileHeightCm),
            ProfileTextField(
              controller: _heightController,
              hint: context.l10n.profileEnterHeight,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 18.h),
            _label(context.l10n.metricAge),
            ProfileTextField(
              controller: _ageController,
              hint: context.l10n.profileEnterAge,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 18.h),
            _label(context.l10n.profileGender),
            SizedBox(height: 10.h),
            Row(
              children: [
                _genderButton("Male"),
                SizedBox(width: 12.w),
                _genderButton("Female"),
              ],
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
                onPressed: () async {
                  final weightText = _weightController.text.trim();

                  final heightText = _heightController.text.trim();

                  final ageText = _ageController.text.trim();

                  if (weightText.isEmpty ||
                      double.tryParse(weightText) == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.profileInvalidWeight),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  if (heightText.isEmpty ||
                      double.tryParse(heightText) == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.profileInvalidHeight),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  if (ageText.isEmpty ||
                      int.tryParse(ageText) == null ||
                      int.parse(ageText) <= 0) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.profileInvalidAge),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  final weight = double.parse(weightText);

                  final height = double.parse(heightText);

                  final age = int.parse(ageText);

                  if (weight <= 0 || height <= 0) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.profilePositiveValues),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  final stepGoal = GoalCalculator.calculateStepGoal(
                    goal,
                    widget.profile.activityLevel,
                  );

                  final calorieGoal = GoalCalculator.calculateDailyCalories(
                    gender: gender,
                    weight: weight,
                    height: height,
                    age: age,
                    activityLevel: widget.profile.activityLevel,
                  );

                  final macros = MacroCalculator.calculate(
                    calories: calorieGoal,
                    goal: goal,
                  );

                  final updatedProfile = ProfileEntity(
                    name: _nameController.text.trim(),
                    email: widget.profile.email,
                    goal: goal,
                    streak: widget.profile.streak,
                    weight: weight,
                    height: height,
                    age: age.toDouble(),
                    gender: gender,
                    photoUrl: widget.profile.photoUrl,
                    dailyStepGoal: stepGoal,
                    dailyCalorieGoal: calorieGoal,
                    proteinGoal: macros["protein"]!.round(),
                    carbsGoal: macros["carbs"]!.round(),
                    fatGoal: macros["fat"]!.round(),
                    activityLevel: widget.profile.activityLevel,
                  );

                  context.read<ProfileBloc>().add(
                    UpdateProfileEvent(updatedProfile),
                  );

                  await Future.delayed(const Duration(milliseconds: 200));

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  context.l10n.profileSave,
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
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _dropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: AppColors.surfaceHigh,
          value: goal,
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          items: goals.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(
                e == 'Fitness Goal'
                    ? context.l10n.goalFitnessGoal
                    : goalLabel(context.l10n, e),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              goal = value;
            });
          },
        ),
      ),
    );
  }

  Widget _genderButton(String value) {
    final isSelected = gender == value;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        inMutuallyExclusiveGroup: true,
        child: GestureDetector(
          onTap: () {
            setState(() {
              gender = value;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Center(
              child: Text(
                genderLabel(context.l10n, value),
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
