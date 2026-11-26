import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/di/injection_container.dart';
import 'package:fitness_app/features/health_calculator/presentation/widgets/calculator_inputs.dart';
import 'package:fitness_app/features/health_calculator/presentation/widgets/calculator_result_card.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/features/health_calculator/presentation/bloc/health_calculator_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/core/l10n/profile_labels.dart';

import '../calculator_labels.dart';

class HealthCalculatorPage extends StatefulWidget {
  final String type;

  const HealthCalculatorPage({super.key, required this.type});

  @override
  State<HealthCalculatorPage> createState() => _HealthCalculatorPageState();
}

class _HealthCalculatorPageState extends State<HealthCalculatorPage> {
  final weightController = TextEditingController();

  final heightController = TextEditingController();

  final ageController = TextEditingController();

  String gender = "Male";

  String goal = "Maintain";

  double activity = 1.55;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HealthCalculatorBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppHeader(
          title: calculatorTypeLabel(context.l10n, widget.type),
        ),
        // AppBar(
        //   backgroundColor:
        //       Colors.transparent,
        //   elevation: 0,
        //   centerTitle: true,
        //   title: Text(
        //     widget.type,
        //     style: TextStyle(
        //       color: Colors.white,
        //       fontSize: 20.sp,
        //       fontWeight:
        //           FontWeight.bold,
        //     ),
        //   ),
        // ),
        body: BlocBuilder<HealthCalculatorBloc, HealthCalculatorState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  _buildHeader(),
                  SizedBox(height: 24.h),
                  if (_needsWeight())
                    CalculatorTextField(
                      controller: weightController,
                      hint: context.l10n.calcWeightHint,
                    ),
                  if (_needsHeight()) ...[
                    SizedBox(height: 16.h),
                    CalculatorTextField(
                      controller: heightController,
                      hint: context.l10n.calcHeightHint,
                    ),
                  ],
                  if (_needsAge()) ...[
                    SizedBox(height: 16.h),
                    CalculatorTextField(
                      controller: ageController,
                      hint: context.l10n.statAge,
                    ),
                  ],
                  if (_needsGender()) ...[
                    SizedBox(height: 16.h),
                    CalculatorDropdown(
                      value: gender,
                      items: const ["Male", "Female"],
                      labelOf: (v) => genderLabel(context.l10n, v),
                      onChanged: (v) {
                        setState(() {
                          gender = v!;
                        });
                      },
                    ),
                  ],
                  if (_needsGoal()) ...[
                    SizedBox(height: 16.h),
                    CalculatorDropdown(
                      value: goal,
                      items: const ["Maintain", "Fat Loss", "Muscle Gain"],
                      labelOf: (v) => proteinGoalLabel(context.l10n, v),
                      onChanged: (v) {
                        setState(() {
                          goal = v!;
                        });
                      },
                    ),
                  ],
                  if (_needsActivity()) ...[
                    SizedBox(height: 20.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.calcActivityLevel,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        Slider(
                          value: activity,
                          min: 1.2,
                          max: 1.9,
                          activeColor: AppColors.primary,
                          onChanged: (v) {
                            setState(() {
                              activity = v;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 30.h),
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
                      onPressed: () {
                        final bloc = context.read<HealthCalculatorBloc>();

                        if (widget.type == "BMI") {
                          final weight = double.tryParse(weightController.text);
                          final height = double.tryParse(heightController.text);
                          if (weight == null ||
                              height == null ||
                              weight <= 0 ||
                              height <= 0) {
                            _showError(
                              context,
                              context.l10n.calcErrWeightHeight,
                            );
                            return;
                          }
                          bloc.add(
                            CalculateBMIEvent(weight: weight, height: height),
                          );
                        } else if (widget.type == "Water Intake") {
                          final weight = double.tryParse(weightController.text);
                          if (weight == null || weight <= 0) {
                            _showError(context, context.l10n.calcErrWeight);
                            return;
                          }
                          bloc.add(CalculateWaterEvent(weight: weight));
                        } else if (widget.type == "Protein") {
                          final weight = double.tryParse(weightController.text);
                          if (weight == null || weight <= 0) {
                            _showError(context, context.l10n.calcErrWeight);
                            return;
                          }
                          bloc.add(
                            CalculateProteinEvent(weight: weight, goal: goal),
                          );
                        } else {
                          final weight = double.tryParse(weightController.text);
                          final height = double.tryParse(heightController.text);
                          final age = int.tryParse(ageController.text);
                          if (weight == null ||
                              height == null ||
                              weight <= 0 ||
                              height <= 0 ||
                              age == null ||
                              age <= 0) {
                            _showError(context, context.l10n.calcErrAll);
                            return;
                          }
                          bloc.add(
                            CalculateCaloriesEvent(
                              weight: weight,
                              height: height,
                              age: age,
                              gender: gender,
                              activity: activity,
                            ),
                          );
                        }
                      },
                      child: Text(
                        context.l10n.calcCalculate,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  if (state is HealthCalculatorLoaded)
                    CalculatorResultCard(state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color.fromARGB(255, 0, 160, 128)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            calculatorTypeLabel(context.l10n, widget.type),
            style: TextStyle(
              color: Colors.black,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            context.l10n.calcTagline,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.7),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }

  bool _needsWeight() => true;

  bool _needsHeight() => widget.type == "BMI" || widget.type == "Calories";

  bool _needsAge() => widget.type == "Calories";

  bool _needsGender() => widget.type == "Calories";

  bool _needsGoal() => widget.type == "Protein";

  bool _needsActivity() => widget.type == "Calories";
}
