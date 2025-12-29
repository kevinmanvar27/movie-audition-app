import 'package:flutter/material.dart';
import 'app_colors.dart';

class CustomDropdown extends StatelessWidget {
  final String labelText;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    required this.labelText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Remove duplicate items to prevent the assertion error
    final uniqueItems = items.toSet().toList();
    
    return DropdownButtonFormField<String>(
      value: uniqueItems.contains(value) ? value : null,
      validator: validator,
      hint: Text('Select $labelText', style: const TextStyle(color: AppColors.textSecondary)),
      dropdownColor: AppColors.background, // Same dropdown menu BG color
      style: const TextStyle(color: AppColors.textPrimary), // Selected text white
      iconEnabledColor: AppColors.textSecondary,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.textPrimary.withOpacity(0.1),

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
      ),

      items: uniqueItems.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(color: AppColors.textPrimary), // Dropdown text white
          ),
        );
      }).toList(),

      onChanged: onChanged,
      // Add this to handle the case where value is not in the items list
      selectedItemBuilder: (BuildContext context) {
        return uniqueItems.map<Widget>((String item) {
          return Text(
            item,
            style: const TextStyle(color: AppColors.textPrimary),
          );
        }).toList();
      },
    );
  }
}