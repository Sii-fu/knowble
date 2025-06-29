// colors.dart
// Defines the color palette for the Knowble app.
// This file contains the AppColors class, which provides static color constants used throughout the app for consistency.
// It is imported by theme.dart and can be used in any widget for color styling.

import 'package:flutter/material.dart';

// AppColors holds all the main color constants for the app's UI.
class AppColors {
  static const Color primary = Color(0xFF6750A4); // Main brand color
  static const Color secondary = Color(0xFF625B71); // Secondary accent
  static const Color background = Colors.white; // Light background
  static const Color darkBackground = Colors.black; // Dark background
  static const Color accent = Color(0xFF7D5260); // Accent color
  static const Color success = Color(0xFF4CAF50); // Success state
  static const Color error = Color(0xFFF44336); // Error state
  static const Color warning = Color(0xFFFFC107); // Warning state
}
