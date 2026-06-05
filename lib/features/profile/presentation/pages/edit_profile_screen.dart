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
      backgroundColor: const Color(0xFF050505),

      appBar: AppHeader(title: "Edit Profile"),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Center(
              child: CircleAvatar(
                radius: 52.r,

                backgroundColor: const Color(0xFF00E5FF),

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

            _label("Full Name"),

            _field(controller: _nameController, hint: "Enter name"),

            SizedBox(height: 18.h),

            _label("Goal"),

            _dropdown(),

            SizedBox(height: 18.h),

            _label("Weight (kg)"),

            _field(
              controller: _weightController,
              hint: "Enter weight",
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 18.h),

            _label("Height (cm)"),

            _field(
              controller: _heightController,
              hint: "Enter height",
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 18.h),

            _label("Age"),

            _field(
              controller: _ageController,
              hint: "Enter age",
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 18.h),

            _label("Gender"),

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
                  backgroundColor: const Color(0xFF00E5FF),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),

                onPressed: () async {
                  final stepGoal = GoalCalculator.calculateStepGoal(
                    goal,
                    widget.profile.activityLevel,
                  );

                  final calorieGoal = GoalCalculator.calculateDailyCalories(
                    gender: gender,

                    weight: double.tryParse(_weightController.text) ?? 0,

                    height: double.tryParse(_heightController.text) ?? 0,

                    age: int.tryParse(_ageController.text) ?? 0,

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

                    weight: double.tryParse(_weightController.text) ?? 0,

                    height: double.tryParse(_heightController.text) ?? 0,

                    age: double.tryParse(_ageController.text) ?? 0,

                    gender: gender,

                    photoUrl: null,

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
                  "Save Profile",

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

  Widget _field({
    required TextEditingController controller,

    required String hint,

    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,

      keyboardType: keyboardType,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),

        filled: true,

        fillColor: Colors.white.withOpacity(0.05),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),

        borderRadius: BorderRadius.circular(18.r),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF1A1A1A),

          value: goal,

          isExpanded: true,

          style: const TextStyle(color: Colors.white),

          items: goals.map((e) {
            return DropdownMenuItem(value: e, child: Text(e));
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
                ? const Color(0xFF00E5FF)
                : Colors.white.withOpacity(0.05),

            borderRadius: BorderRadius.circular(18.r),
          ),

          child: Center(
            child: Text(
              value,

              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,

                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
