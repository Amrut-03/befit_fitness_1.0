import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Phone-sized surface matching the app's ScreenUtil design size.
const testScreenSize = Size(375, 812);

extension PumpApp on WidgetTester {
  Future<void> _setPhoneSize() async {
    view.physicalSize = testScreenSize * 3;
    view.devicePixelRatio = 3;
    addTearDown(view.reset);
  }

  /// Pumps [home] inside the app's theme and ScreenUtil, at phone size.
  Future<void> pumpApp(Widget home) async {
    await _setPhoneSize();
    await pumpWidget(
      ScreenUtilInit(
        designSize: testScreenSize,
        builder: (_, _) => MaterialApp(theme: AppTheme.dark, home: home),
      ),
    );
  }

  /// Pumps a router-based app for pages that navigate with go_router.
  /// [wrap] places providers above every route, like `UserScope` in main.
  Future<void> pumpRouterApp(
    GoRouter router, {
    Widget Function(Widget child)? wrap,
  }) async {
    await _setPhoneSize();
    await pumpWidget(
      ScreenUtilInit(
        designSize: testScreenSize,
        builder: (_, _) => MaterialApp.router(
          theme: AppTheme.dark,
          routerConfig: router,
          builder: (_, child) => wrap?.call(child!) ?? child!,
        ),
      ),
    );
  }

  /// Lottie loaders animate forever, so pumpAndSettle would time out.
  Future<void> pumpForLoaders([int frames = 5]) async {
    for (var i = 0; i < frames; i++) {
      await pump(const Duration(milliseconds: 100));
    }
  }
}
