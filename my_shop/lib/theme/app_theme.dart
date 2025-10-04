import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D32),
        useMaterial3: true,
      );
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF80CBC4),
        useMaterial3: true,
      );
}