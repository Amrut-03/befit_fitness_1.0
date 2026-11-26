import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/l10n/locale_cubit.dart';
import 'package:fitness_app/core/l10n/profile_labels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

Map<String, dynamic> _arb(String code) =>
    jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _placeholders(String text) =>
    RegExp(r'\{(\w+)').allMatches(text).map((m) => m.group(1)!).toSet();

void main() {
  tearDown(() => AppLocale.chosen = null);

  group('ARB files', () {
    final en = _arb('en');
    final keys = en.keys.where((k) => !k.startsWith('@')).toSet();

    for (final code in ['hi', 'mr']) {
      test('$code has every English key, with the same placeholders', () {
        final other = _arb(code);
        final otherKeys = other.keys.where((k) => !k.startsWith('@')).toSet();
        expect(otherKeys.difference(keys), isEmpty, reason: 'extra keys');
        expect(keys.difference(otherKeys), isEmpty, reason: 'missing keys');
        for (final k in keys) {
          final source = en[k] as String;
          final translated = other[k] as String;
          expect(translated.trim(), isNotEmpty, reason: k);
          // Plural/select bodies use their own words; only check simple ones.
          if (!source.contains(', plural,') && !source.contains(', select,')) {
            expect(
              _placeholders(translated),
              _placeholders(source),
              reason: '$code.$k',
            );
          }
        }
      });
    }
  });

  group('AppLocale.resolve', () {
    test('picks the first supported phone language', () {
      expect(
        AppLocale.resolve(const [Locale('fr'), Locale('mr', 'IN')]),
        const Locale('mr'),
      );
      expect(AppLocale.resolve(const [Locale('hi', 'IN')]), const Locale('hi'));
    });

    test('falls back to English', () {
      expect(AppLocale.resolve(const [Locale('ta')]), const Locale('en'));
      expect(AppLocale.resolve(const []), const Locale('en'));
    });
  });

  test('AppLocale follows the chosen language', () {
    AppLocale.chosen = const Locale('hi');
    expect(AppLocale.languageName, 'Hindi');
    expect(AppLocale.l10n.commonRetry, isNot('Retry'));

    AppLocale.chosen = const Locale('mr');
    expect(AppLocale.languageName, 'Marathi');

    AppLocale.chosen = const Locale('en');
    expect(AppLocale.languageName, 'English');
    expect(AppLocale.l10n.commonRetry, 'Retry');
  });

  test('stored English values are shown translated', () {
    final hi = lookupAppLocalizations(const Locale('hi'));
    expect(goalLabel(hi, 'Lose Weight'), hi.goalLoseWeight);
    expect(mealLabel(hi, 'Breakfast'), hi.mealBreakfast);
    expect(goalLabel(hi, 'Custom goal'), 'Custom goal');
  });

  group('LocaleCubit', () {
    late Directory dir;
    late Box<dynamic> box;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('hive_locale');
      Hive.init(dir.path);
      box = await Hive.openBox('settings');
    });

    tearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    test('defaults to the phone language (null)', () {
      expect(LocaleCubit(box).state, isNull);
      expect(AppLocale.chosen, isNull);
    });

    test('persists the choice and syncs AppLocale', () async {
      var changes = 0;
      final cubit = LocaleCubit(box, onChanged: () => changes++);

      await cubit.setLocale(const Locale('mr'));
      expect(cubit.state, const Locale('mr'));
      expect(AppLocale.current, const Locale('mr'));
      expect(changes, 1);

      AppLocale.chosen = null;
      expect(LocaleCubit(box).state, const Locale('mr'), reason: 'restored');
      expect(AppLocale.chosen, const Locale('mr'));
    });

    test('choosing the same language again is a no-op', () async {
      var changes = 0;
      final cubit = LocaleCubit(box, onChanged: () => changes++);
      await cubit.setLocale(const Locale('hi'));
      await cubit.setLocale(const Locale('hi'));
      expect(changes, 1);
    });

    test('null goes back to following the phone', () async {
      final cubit = LocaleCubit(box);
      await cubit.setLocale(const Locale('hi'));
      await cubit.setLocale(null);
      expect(LocaleCubit(box).state, isNull);
      expect(AppLocale.chosen, isNull);
    });
  });
}
