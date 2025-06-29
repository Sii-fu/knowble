// custom_button.dart
// Defines a reusable styled button widget for Knowble.
// This file contains the CustomButton widget, which can be used throughout the app for consistent button styles.
// Accepts a label, onPressed callback, and an optional filled style.

import 'package:flutter/material.dart';

// CustomButton is a reusable button with optional filled/outlined style.
class CustomButton extends StatelessWidget {
  final String label; // Button text
  final VoidCallback onPressed; // Callback when pressed
  final bool filled; // Whether the button is filled or outlined

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: filled
          ? null // Default filled style
          : ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
