import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'l10n.dart';

/// The language the user picked, or null to follow the phone. Stored on the
/// device (not per account).
class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._box, {this.onChanged}) : super(_read(_box)) {
    AppLocale.chosen = state;
  }

  final Box _box;

  /// Called after the language changes (e.g. to reschedule reminders so their
  /// text is in the new language).
  final VoidCallback? onChanged;

  static const _key = 'locale';

  static Locale? _read(Box box) {
    final code = box.get(_key);
    if (code is! String) return null;
    for (final l in appLocales) {
      if (l.languageCode == code) return l;
    }
    return null;
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == state) return;
    AppLocale.chosen = locale;
    emit(locale);
    if (locale == null) {
      await _box.delete(_key);
    } else {
      await _box.put(_key, locale.languageCode);
    }
    onChanged?.call();
  }
}
