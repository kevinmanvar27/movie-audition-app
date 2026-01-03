import 'package:flutter/material.dart';

/// Utility class for responsive text sizing
/// Automatically increases font size by 4 on tablets
class ResponsiveText {
  /// Check if the device is a tablet (width >= 600)
  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  /// Get responsive font size - adds 4 to base size on tablets
  static double fontSize(BuildContext context, double baseSize) {
    return isTablet(context) ? baseSize + 4 : baseSize;
  }

  /// Get responsive icon size - adds 4 to base size on tablets
  static double iconSize(BuildContext context, double baseSize) {
    return isTablet(context) ? baseSize + 4 : baseSize;
  }

  /// Get responsive padding - scales by 1.2x on tablets
  static double padding(BuildContext context, double basePadding) {
    return isTablet(context) ? basePadding * 1.2 : basePadding;
  }

  /// Create a responsive TextStyle
  static TextStyle textStyle(
    BuildContext context, {
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: ResponsiveText.fontSize(context, fontSize),
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }
}

/// Extension on TextStyle for easy responsive conversion
extension ResponsiveTextStyle on TextStyle {
  /// Convert this TextStyle to responsive (adds 4 to fontSize on tablets)
  TextStyle responsive(BuildContext context) {
    final currentSize = fontSize ?? 14;
    return copyWith(
      fontSize: ResponsiveText.fontSize(context, currentSize),
    );
  }
}
