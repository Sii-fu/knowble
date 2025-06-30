// main.dart
// Entry point of the Knowble app.
// This file contains the main() function, which runs the app by calling runApp(MyApp()).
// It connects to app.dart, which sets up MaterialApp, routes, and themes.

import 'package:flutter/material.dart';
import 'app.dart';
// import '../features/instructor/course_screen.dart';

void main() {
  // The root of the app. MyApp is defined in app.dart.
  runApp(const MyApp());
}
