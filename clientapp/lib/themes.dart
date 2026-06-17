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
        Color(0xFF0F172A),
        Color(0xFF1E293B),
        Color.fromARGB(0, 200, 114, 250),
        Color(0xFF38BDF8),
        Color(0xFFE2E8F0),
        Color(0xFFF8FAFC),
      );
    } else {
      // Light theme
      colors = AppTheme(
        Color(0xFFF8FAFC),
        Color(0xFFE2E8F0),
        Color.fromARGB(0, 200, 114, 250),
        Color(0xFF0284C7),
        Color(0xFF1E293B),
        Color(0xFF0F172A),
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
