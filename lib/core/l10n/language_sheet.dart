import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'l10n.dart';
import 'locale_cubit.dart';

/// Name of [locale] in its own language (or "Phone language" for null).
String languageLabel(AppLocalizations l10n, Locale? locale) =>
    switch (locale?.languageCode) {
      null => l10n.languageSystem,
      'hi' => l10n.languageHindi,
      'mr' => l10n.languageMarathi,
      _ => l10n.languageEnglish,
    };

Future<void> showLanguageSheet(BuildContext context) {
  final cubit = context.read<LocaleCubit>();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      return SafeArea(
        child: BlocBuilder<LocaleCubit, Locale?>(
          bloc: cubit,
          builder: (context, selected) => RadioGroup<String>(
            groupValue: selected?.languageCode ?? '',
            onChanged: (code) {
              cubit.setLocale(
                code == null || code.isEmpty ? null : Locale(code),
              );
              Navigator.pop(sheetContext);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    l10n.languageTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                for (final locale in <Locale?>[null, ...appLocales])
                  RadioListTile<String>(
                    value: locale?.languageCode ?? '',
                    activeColor: AppColors.primary,
                    title: Text(languageLabel(l10n, locale)),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
