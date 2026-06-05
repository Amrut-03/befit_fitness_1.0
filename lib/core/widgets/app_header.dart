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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          context.pop(context);
        },
      ),
      centerTitle: centerTitle,
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xFF00E5FF),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 22.sp,
          fontWeight: FontWeight.w800,

          letterSpacing: 0.5,
        ),
      ),

      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50.h);
}
