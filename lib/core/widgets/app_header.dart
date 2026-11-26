import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;

  const AppHeader({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading:
          leading ??
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: _onPrimary),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => context.pop(),
          ),
      centerTitle: centerTitle,
      // Dark on the bright cyan bar: white on it fails contrast (1.5:1).
      iconTheme: const IconThemeData(color: _onPrimary),
      actionsIconTheme: const IconThemeData(color: _onPrimary),
      foregroundColor: _onPrimary,
      backgroundColor: AppColors.primary,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: _onPrimary,
          fontSize: 22.sp,
          fontWeight: FontWeight.w800,

          letterSpacing: 0.5,
        ),
      ),

      actions: actions,
    );
  }

  static const _onPrimary = AppColors.onPrimary;

  @override
  Size get preferredSize => Size.fromHeight(50.h);
}
