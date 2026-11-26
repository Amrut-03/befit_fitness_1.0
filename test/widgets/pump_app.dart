import 'package:fitness_app/core/accessibility/app_text_scaling.dart';
import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Localization delegates, as in `main.dart`.
const testLocalizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// The phone's font-size setting for the next pump. Set it with
/// [PumpApp.setTextScale] so it resets after the test.
double _textScale = 1.0;

/// Applies the phone's font size and the app's cap, as `main.dart` does.
Widget _scaled(BuildContext context, Widget child) => MediaQuery(
  data: MediaQuery.of(
    context,
  ).copyWith(textScaler: TextScaler.linear(_textScale)),
  child: AppTextScaling(child: child),
);

/// Phone-sized surface matching the app's ScreenUtil design size.
const testScreenSize = Size(375, 812);

extension PumpApp on WidgetTester {
  /// Simulates the phone's font size (1.0 = default) for this test.
  void setTextScale(double scale) {
    _textScale = scale;
    addTearDown(() => _textScale = 1.0);
  }

  Future<void> _setPhoneSize() async {
    view.physicalSize = testScreenSize * 3;
    view.devicePixelRatio = 3;
    addTearDown(view.reset);
  }

  /// Pumps [home] inside the app's theme and ScreenUtil, at phone size.
  /// [locale] defaults to English.
  Future<void> pumpApp(
    Widget home, {
    Locale locale = const Locale('en'),
  }) async {
    await _setPhoneSize();
    await pumpWidget(
      ScreenUtilInit(
        designSize: testScreenSize,
        builder: (_, _) => MaterialApp(
          theme: AppTheme.dark,
          locale: locale,
          supportedLocales: appLocales,
          localizationsDelegates: testLocalizationsDelegates,
          builder: (context, child) => _scaled(context, child!),
          home: home,
        ),
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
          locale: const Locale('en'),
          supportedLocales: appLocales,
          localizationsDelegates: testLocalizationsDelegates,
          routerConfig: router,
          builder: (context, child) =>
              _scaled(context, wrap?.call(child!) ?? child!),
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
