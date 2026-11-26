import 'dart:math';

import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.1 contrast ratio of [fg] drawn over [bg] (alpha blended).
double contrast(Color fg, Color bg) {
  final blended = Color.alphaBlend(fg, bg);
  double lum(Color c) {
    double ch(double v) =>
        v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
  }

  final a = lum(blended), b = lum(bg);
  return (max(a, b) + 0.05) / (min(a, b) + 0.05);
}

void main() {
  // Cards and sheets sit on these; text must read on all of them.
  const surfaces = {
    'background': AppColors.background,
    'black': Colors.black,
    'surface': AppColors.surface,
    'surfaceElevated': AppColors.surfaceElevated,
    'surfaceHigh': AppColors.surfaceHigh,
    'surfaceNavy': AppColors.surfaceNavy,
  };

  // Body text: WCAG AA 4.5:1.
  const bodyText = {
    'textPrimary': AppColors.textPrimary,
    'textSecondary': AppColors.textSecondary,
    'textMuted': AppColors.textMuted,
    'primary': AppColors.primary,
    'water': AppColors.water,
    'success': AppColors.success,
    'warning': AppColors.warning,
    'error': AppColors.error,
    'accentOrange': AppColors.accentOrange,
  };

  for (final s in surfaces.entries) {
    for (final t in bodyText.entries) {
      test('${t.key} on ${s.key} is at least 4.5:1', () {
        expect(contrast(t.value, s.value), greaterThanOrEqualTo(4.5));
      });
    }
  }

  test('accentPink is only for large text and icons (3:1)', () {
    for (final s in surfaces.values) {
      expect(contrast(AppColors.accentPink, s), greaterThanOrEqualTo(3));
    }
  });

  test('onPrimary on the cyan header and buttons is at least 7:1', () {
    expect(
      contrast(AppColors.onPrimary, AppColors.primary),
      greaterThanOrEqualTo(7),
    );
  });

  test('white on the cyan primary fails, so it must not be used there', () {
    expect(contrast(Colors.white, AppColors.primary), lessThan(3));
  });
}
