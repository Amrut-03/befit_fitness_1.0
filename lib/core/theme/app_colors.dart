import 'package:flutter/material.dart';

/// Colour tokens for the app's dark, neon-accent look. Use these instead of
/// hex literals so the palette can change in one place.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF00E5FF);
  static const Color accentPink = Color(0xFFFF006E);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color warning = Color(0xFFFFB703);
  static const Color water = Color(0xFF4D96FF);

  // Surfaces, darkest first
  static const Color background = Color(0xFF050505);
  static const Color surfaceDim = Color(0xFF0B0B0B);
  static const Color surface = Color(0xFF111111);
  static const Color surfaceElevated = Color(0xFF171717);
  static const Color surfaceHigh = Color(0xFF1A1A1A);
  static const Color surfaceNavy = Color(0xFF09111F);

  // Text on dark surfaces
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white54;

  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF06D6A0);
}
