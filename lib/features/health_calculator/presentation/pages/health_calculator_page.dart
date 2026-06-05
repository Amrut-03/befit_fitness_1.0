import 'package:fitness_app/core/di/injection_container.dart';
import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/features/health_calculator/presentation/bloc/health_calculator_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        backgroundColor: const Color(0xFF050505),

        appBar: AppHeader(title: widget.type),

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
                    _buildTextField(
                      controller: weightController,
                      hint: "Weight (kg)",
                    ),

                  if (_needsHeight()) ...[
                    SizedBox(height: 16.h),

                    _buildTextField(
                      controller: heightController,
                      hint: "Height (cm)",
                    ),
                  ],

                  if (_needsAge()) ...[
                    SizedBox(height: 16.h),

                    _buildTextField(controller: ageController, hint: "Age"),
                  ],

                  if (_needsGender()) ...[
                    SizedBox(height: 16.h),

                    _buildDropdown(
                      value: gender,
                      items: const ["Male", "Female"],
                      onChanged: (v) {
                        setState(() {
                          gender = v!;
                        });
                      },
                    ),
                  ],

                  if (_needsGoal()) ...[
                    SizedBox(height: 16.h),

                    _buildDropdown(
                      value: goal,
                      items: const ["Maintain", "Fat Loss", "Muscle Gain"],
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
                          "Activity Level",

                          style: TextStyle(
                            color: Colors.white,

                            fontSize: 14.sp,
                          ),
                        ),

                        Slider(
                          value: activity,

                          min: 1.2,

                          max: 1.9,

                          activeColor: const Color(0xFF00E5FF),

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
                        backgroundColor: const Color(0xFF00E5FF),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),

                      onPressed: () {
                        final bloc = context.read<HealthCalculatorBloc>();

                        if (widget.type == "BMI") {
                          bloc.add(
                            CalculateBMIEvent(
                              weight: double.parse(weightController.text),

                              height: double.parse(heightController.text),
                            ),
                          );
                        } else if (widget.type == "Water Intake") {
                          bloc.add(
                            CalculateWaterEvent(
                              weight: double.parse(weightController.text),
                            ),
                          );
                        } else if (widget.type == "Protein") {
                          bloc.add(
                            CalculateProteinEvent(
                              weight: double.parse(weightController.text),

                              goal: goal,
                            ),
                          );
                        } else {
                          bloc.add(
                            CalculateCaloriesEvent(
                              weight: double.parse(weightController.text),

                              height: double.parse(heightController.text),

                              age: int.parse(ageController.text),

                              gender: gender,

                              activity: activity,
                            ),
                          );
                        }
                      },

                      child: Text(
                        "Calculate",

                        style: TextStyle(
                          color: Colors.black,

                          fontSize: 16.sp,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  if (state is HealthCalculatorLoaded) _buildResultCard(state),
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
          colors: [Color(0xFF00E5FF), Color.fromARGB(255, 0, 160, 128)],
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            widget.type,

            style: TextStyle(
              color: Colors.black,

              fontSize: 24.sp,

              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            "Track your fitness smarter",

            style: TextStyle(
              color: Colors.black.withOpacity(0.7),

              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,

    required String hint,
  }) {
    return TextField(
      controller: controller,

      keyboardType: TextInputType.number,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),

        filled: true,

        fillColor: Colors.white.withOpacity(0.05),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,

    required List<String> items,

    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),

        borderRadius: BorderRadius.circular(18.r),
      ),

      child: DropdownButton<String>(
        dropdownColor: const Color(0xFF111111),

        value: value,

        isExpanded: true,

        underline: const SizedBox(),

        style: const TextStyle(color: Colors.white),

        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),

        onChanged: onChanged,
      ),
    );
  }

  Widget _buildResultCard(HealthCalculatorLoaded state) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(24.w),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),

        color: Colors.white.withOpacity(0.05),
      ),

      child: Column(
        children: [
          Text(
            state.result.value.toString(),

            style: TextStyle(
              color: const Color(0xFF00E5FF),

              fontSize: 40.sp,

              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10.h),

          Text(
            state.result.title,

            style: TextStyle(
              color: Colors.white,

              fontSize: 18.sp,

              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            state.result.description,

            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.white.withOpacity(0.6),

              fontSize: 13.sp,
            ),
          ),
        ],
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
