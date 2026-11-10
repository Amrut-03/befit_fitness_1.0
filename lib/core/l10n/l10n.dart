import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart' show BuildContext;

export 'package:fitness_app/l10n/app_localizations.dart';

/// Languages BeFit ships. Order drives the language picker.
const appLocales = [Locale('en'), Locale('hi'), Locale('mr')];

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// The app's current language for code that has no [BuildContext]: blocs'
/// user-facing messages, scheduled notifications and AI prompts.
///
/// [LocaleCubit] keeps it in sync with the user's choice. Widgets use
/// `context.l10n` instead.
abstract final class AppLocale {
  /// The user's explicit choice, or null to follow the phone.
  static Locale? chosen;

  /// The language in effect: the choice, else the phone's language when
  /// supported, else English.
  static Locale get current =>
      chosen ?? resolve(PlatformDispatcher.instance.locales);

  static AppLocalizations get l10n => lookupAppLocalizations(current);

  /// Picks the first supported language from [preferred].
  static Locale resolve(Iterable<Locale> preferred) {
    for (final p in preferred) {
      for (final s in appLocales) {
        if (s.languageCode == p.languageCode) return s;
      }
    }
    return appLocales.first;
  }

  /// English name of the current language, for AI prompts.
  static String get languageName => switch (current.languageCode) {
    'hi' => 'Hindi',
    'mr' => 'Marathi',
    _ => 'English',
  };
}
