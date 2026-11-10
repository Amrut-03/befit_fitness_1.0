import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Asks for an amount in ml. Returns null when dismissed.
///
/// Used for a custom drink and for editing the daily goal.
Future<int?> showWaterAmountSheet(
  BuildContext context, {
  required String title,
  required int min,
  required int max,
  int? initialMl,
  String? hint,
  String? confirmLabel,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceElevated,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) => _WaterAmountSheet(
      title: title,
      min: min,
      max: max,
      initialMl: initialMl,
      hint: hint,
      confirmLabel: confirmLabel,
    ),
  );
}

class _WaterAmountSheet extends StatefulWidget {
  const _WaterAmountSheet({
    required this.title,
    required this.min,
    required this.max,
    required this.confirmLabel,
    this.initialMl,
    this.hint,
  });

  final String title;
  final int min;
  final int max;
  final int? initialMl;
  final String? hint;
  final String? confirmLabel;

  @override
  State<_WaterAmountSheet> createState() => _WaterAmountSheetState();
}

class _WaterAmountSheetState extends State<_WaterAmountSheet> {
  late final _controller = TextEditingController(
    text: widget.initialMl?.toString() ?? '',
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final ml = int.tryParse(_controller.text.trim());
    if (ml == null || ml < widget.min || ml > widget.max) {
      setState(
        () => _error = context.l10n.waterEnterBetween(widget.min, widget.max),
      );
      return;
    }
    Navigator.of(context).pop(ml);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        20.h,
        20.w,
        20.h + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.hint != null) ...[
            SizedBox(height: 6.h),
            Text(
              widget.hint!,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
            ),
          ],
          SizedBox(height: 20.h),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: AppColors.textPrimary),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: context.l10n.waterAmount,
              hintStyle: const TextStyle(color: AppColors.textMuted),
              suffixText: 'ml',
              suffixStyle: const TextStyle(color: AppColors.water),
              errorText: _error,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.water,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              onPressed: _submit,
              child: Text(widget.confirmLabel ?? context.l10n.commonSave),
            ),
          ),
        ],
      ),
    );
  }
}
