// app.dart
// Configures the main MaterialApp for Knowble.
// This file defines the MyApp widget, which sets up the app's theme, routes, and root navigation.
// It imports theme.dart for theming and routes.dart for navigation.
// All screens and navigation logic are ultimately connected through this file.

import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/routes.dart';

// MyApp is the root widget of the app. It sets up MaterialApp with theming and routing.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Knowble',
      theme: AppTheme.lightTheme, // Light theme from config/theme.dart
      darkTheme: AppTheme.darkTheme, // Dark theme from config/theme.dart
      themeMode: ThemeMode.system, // Follows system theme
      initialRoute: AppRoutes.initial, // Initial route from config/routes.dart
      routes: AppRoutes.routes, // All named routes
      debugShowCheckedModeBanner: false, // Hides debug banner
    );
  }
}
