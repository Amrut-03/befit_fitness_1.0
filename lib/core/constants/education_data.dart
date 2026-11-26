import 'package:fitness_app/core/l10n/l10n.dart';

import '../models/education_info.dart';

abstract final class EducationData {
  static EducationInfo overallHealth(AppLocalizations l10n) => EducationInfo(
    emoji: '❤️',
    title: l10n.eduHealthTitle,
    description: l10n.eduHealthDescription,
    whyImportant: l10n.eduHealthWhy,
    tips: [
      l10n.eduHealthTip1,
      l10n.eduHealthTip2,
      l10n.eduHealthTip3,
      l10n.eduHealthTip4,
      l10n.eduHealthTip5,
    ],
  );

  static EducationInfo bodyChart(AppLocalizations l10n) => EducationInfo(
    emoji: '💪',
    title: l10n.eduBodyTitle,
    description: l10n.eduBodyDescription,
    whyImportant: l10n.eduBodyWhy,
    tips: [
      l10n.eduBodyTip1,
      l10n.eduBodyTip2,
      l10n.eduBodyTip3,
      l10n.eduBodyTip4,
      l10n.eduBodyTip5,
      l10n.eduBodyTip6,
    ],
  );
}
