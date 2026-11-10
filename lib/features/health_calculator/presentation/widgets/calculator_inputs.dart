import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalculatorTextField extends StatelessWidget {
  const CalculatorTextField({
    super.key,
    required this.controller,
    required this.hint,
  });

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class CalculatorDropdown extends StatelessWidget {
  const CalculatorDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelOf,
  });

  final String value;
  final List<String> items;
  final Function(String?) onChanged;

  /// Display text for a stored value; defaults to the value itself.
  final String Function(String)? labelOf;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: DropdownButton<String>(
        dropdownColor: AppColors.surface,
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(labelOf?.call(e) ?? e),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
