import 'package:flutter/material.dart';

class AppTheme {
  static late AppTheme colors;
  static late bool darkMode;

  static void init(BuildContext context) {
    darkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    // darkMode = true; // REMOVE BEFORE FLIGHT
    if (darkMode) {
      // Dark theme
      colors = AppTheme(
        const Color(0xFF0B1220),
        const Color(0xFF172033),
        const Color(0xFF243046),
        const Color(0xFF38BDF8),
        const Color(0xFFF8FAFC),
        const Color(0xFFBFDBFE),
      );
    } else {
      // Light theme
      colors = AppTheme(
        const Color(0xFFF8FAFC),
        const Color(0xFFE2E8F0),
        const Color(0xFFCBD5E1),
        const Color(0xFF0EA5E9),
        const Color(0xFF0F172A),
        const Color(0xFF0284C7),
      );
    }
  }

  final Color background;
  final Color primary; // main components
  final Color secondary; // subcomponents
  final Color tertiary = Color(0xFF1E293B); // map overlay icons
  final Color accent; // highlighted components
  final Color neutral; // fonts and icons
  final Color neutralAccent; // highlighted fonts and icons

  AppTheme(
    this.background,
    this.primary,
    this.secondary,
    this.accent,
    this.neutral,
    this.neutralAccent,
  );
}
