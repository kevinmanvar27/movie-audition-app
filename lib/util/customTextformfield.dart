import 'package:flutter/material.dart';
import 'app_colors.dart';

// Custom styled TextField
class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLines;
  final Function(String)? onChanged;
  final bool readOnly; // Add readOnly parameter
  final GestureTapCallback? onTap; // Add onTap parameter
  final int? maxLength; // Add maxLength parameter

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
    this.readOnly = false, // Default to false
    this.onTap, // Add onTap parameter
    this.maxLength, // Add maxLength parameter
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength, // Add maxLength property
      style: const TextStyle(color: AppColors.textPrimary),
      // Align text at the top for multi-line fields
      textAlignVertical: maxLines == 1 ? TextAlignVertical.center : TextAlignVertical.top,
      onChanged: onChanged,
      readOnly: readOnly, // Add readOnly property
      onTap: onTap, // Add onTap property
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.borderFocused, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.borderError, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.borderError, width: 2.0),
        ),
        filled: true,
        fillColor: AppColors.textPrimary.withOpacity(0.1),
        // Align label at the top for multi-line fields
        alignLabelWithHint: maxLines != 1,
      ),
    );
  }
}