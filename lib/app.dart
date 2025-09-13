// app.dart
// Configures the main MaterialApp for Knowble.
// This file defines the MyApp widget, which sets up the app's theme, routes, and root navigation.
// It imports theme.dart for theming and routes.dart for navigation.
// All screens and navigation logic are ultimately connected through this file.

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'core/services/notification_manager.dart';

// MyApp is the root widget of the app. It sets up MaterialApp with theming and routing.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App came back to foreground - reinitialize notification service
        print('📱 App resumed - reinitializing notification service');
        NotificationManager.reinitialize();
        break;
      case AppLifecycleState.paused:
        // App went to background
        print('📱 App paused');
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        print('📱 App detached');
        break;
      case AppLifecycleState.inactive:
        // App is inactive (e.g., phone call)
        print('📱 App inactive');
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        print('📱 App hidden');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Knowble',
          theme: AppTheme.lightTheme, // Light theme from config/theme.dart
          darkTheme: AppTheme.darkTheme, // Dark theme from config/theme.dart
          themeMode: ThemeMode.system, // Follows system theme
          initialRoute:
              AppRoutes.initial, // Initial route from config/routes.dart
          routes: AppRoutes.routes, // All named routes
          debugShowCheckedModeBanner: false, // Hides debug banner
        );
      },
    );
  }
}
