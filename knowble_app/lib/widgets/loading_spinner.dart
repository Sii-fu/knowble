// loading_spinner.dart
// Defines a centered loading spinner widget for Knowble.
// This file contains the LoadingSpinner widget, which displays a CircularProgressIndicator centered in its parent.
// Useful for showing loading states throughout the app.

import 'package:flutter/material.dart';

// LoadingSpinner is a reusable widget for loading states.
class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    // Center the spinner in its parent
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
