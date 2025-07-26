// main.dart
// Entry point of the Knowble app.
// This file contains the main() function, which runs the app by calling runApp(MyApp()).
// It connects to app.dart, which sets up MaterialApp, routes, and themes.

import 'package:flutter/material.dart';
import 'app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import '../features/instructor/course_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bwlkahcglanmmtfcuktp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3bGthaGNnbGFubW10ZmN1a3RwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEyMjI0MjEsImV4cCI6MjA2Njc5ODQyMX0.znzlkDWQln4UG1zRGyvinX3GGH7zdxBDCGT85b-Xbm8',
    authOptions: const FlutterAuthClientOptions(
      detectSessionInUri: false, // Disable deep link detection to prevent the error
    ),
  );
  // if (Supabase.instance.client != null) {
  //   print('connecteddddddddddddddd');
  // }

  // The root of the app. MyApp is defined in app.dart.
  runApp(const MyApp());
}
