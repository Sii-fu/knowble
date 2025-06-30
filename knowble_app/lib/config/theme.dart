// theme.dart
// Defines the app's light and dark themes, color scheme, and text styles for Knowble.
// This file contains the AppTheme class, which is imported by app.dart to provide theming to the entire app.
// All widgets and screens use these theme settings for consistent styling.

import 'package:flutter/material.dart';

// AppTheme provides static ThemeData for both light and dark modes.
class AppTheme {
  // The primary color for the app, used throughout the color scheme.
  static const Color primaryColor = Color(0xFF6750A4);

  // Light theme configuration
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      bodyMedium: TextStyle(fontSize: 16),
    ),
  );

  // Dark theme configuration
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.dark),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      bodyMedium: TextStyle(fontSize: 16),
    ),
  );
}
