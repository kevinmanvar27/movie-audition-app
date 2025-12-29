import 'package:flutter/material.dart';

/// Centralized color scheme for the Movie Audition app
/// Changing colors here will automatically apply throughout the app
class AppColors {
  // Primary color scheme
  static const Color primary = Color(0xFF383950); // Deep blue-grey
  static const Color secondary = Color(0xFFFF8F71); // Peach
  static const Color accent = Color(0xFFEF2D1A); // Red
  
  // Background colors
  static const Color background = Color(0xFF383950); // Same as primary
  static const Color cardBackground = Color(0xFF5A5B70); // Lighter shade for cards
  static const Color scaffoldBackground = Color(0xFF2C2D42); // Darker shade for scaffold
  
  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textDisabled = Colors.white30;
  static const Color textError = Color(0xFFEF2D1A); // Same as accent
  
  // Border colors
  static const Color border = Colors.white30;
  static const Color borderFocused = Color(0xFFFF8F71); // Same as secondary
  static const Color borderError = Color(0xFFEF2D1A); // Same as accent
  
  // Status colors
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color error = Color(0xFFEF2D1A); // Same as accent
  
  // Button colors
  static const Color buttonPrimaryStart = Color(0xFFFF8F71); // Same as secondary
  static const Color buttonPrimaryEnd = Color(0xFFEF2D1A); // Same as accent
  static const Color buttonSecondary = Colors.transparent;
  
  // Gradient for buttons and other UI elements
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF8F71), Color(0xFFEF2D1A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}