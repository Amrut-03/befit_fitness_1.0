import 'package:fitness_app/core/accessibility/app_text_scaling.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_app.dart';

/// Flutter's accessibility guidelines: 48×48 (Android) and 44×44 (iOS) tap
/// targets, every tappable labelled, and WCAG AA text contrast.
///
/// Call [WidgetTester.ensureSemantics] before pumping; pass the handle here.
Future<void> expectAccessible(
  WidgetTester t,
  SemanticsHandle handle, {
  bool contrast = true,
}) async {
  final guidelines = [
    androidTapTargetGuideline,
    iOSTapTargetGuideline,
    labeledTapTargetGuideline,
    if (contrast) textContrastGuideline,
  ];
  final failures = <String>[];
  for (final g in guidelines) {
    final result = await g.evaluate(t);
    if (!result.passed) failures.add('${g.description}:\n${result.reason}');
  }
  handle.dispose();
  expect(failures, isEmpty, reason: failures.join('\n\n'));
}

/// Sets the largest font size the app supports; pump afterwards and check
/// that nothing overflowed with [expectNoOverflow].
void useLargestText(WidgetTester t) => t.setTextScale(AppTextScaling.maxScale);

/// Layout overflows are reported as exceptions during the pump.
void expectNoOverflow(WidgetTester t) {
  final errors = <Object>[];
  Object? e;
  while ((e = t.takeException()) != null) {
    errors.add(e is FlutterError ? e.toStringDeep() : e!);
  }
  expect(errors, isEmpty, reason: 'layout errors at large text');
}
