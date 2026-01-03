import 'package:flutter/material.dart';
// ignore: unused_import - kept for potential future use
import '../util/customTextformfield.dart';
import '../util/custombutton.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../util/app_colors.dart';
import '../util/responsive_text.dart';
// ignore: unused_import - kept for potential toast notifications
import 'package:fluttertoast/fluttertoast.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Changing password..."),
              ],
            ),
          );
        },
      );

      try {
        final sessionManager = SessionManager();
        final token = sessionManager.authToken;

        if (token == null) {
          Navigator.of(context).pop(); // Dismiss loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication error. Please log in again.'),
            ),
          );
          return;
        }

        final response = await ApiService.changePassword(
          currentPassword: _currentPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
          confirmPassword: _confirmPasswordController.text.trim(),
          token: token,
        );

        Navigator.of(context).pop(); // Dismiss loading dialog

        if (response != null) {
          if (response.success == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response.message ?? 'Password changed successfully!',
                ),
              ),
            );

            // Clear the form
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
          } else {
            String errorMessage =
                response.message ??
                'Failed to change password. Please try again.';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(
                content: Text(errorMessage,
                    style: const TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white)); // White background
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to change password. Please check your connection and try again.',
                style: TextStyle(color: Colors.black), // Black text
              ),
              backgroundColor: Colors.white, // White background
            ),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        print('Exception during password change: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while changing the password'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(title: 'Change Password'),
      endDrawer: CustomDrawer(),
      backgroundColor: const Color(0xFF383950),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              Text(
                'Enter your current password and new password to change your password.',
                textAlign: TextAlign.center,
                style: ResponsiveText.textStyle(context, fontSize: 16, color: Colors.white70),
              ),

              const SizedBox(height: 30),

              // Current Password Field
              TextFormField(
                controller: _currentPasswordController,
                obscureText: !_isCurrentPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: AppColors.borderFocused,
                      width: 2.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: AppColors.borderError,
                      width: 2.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: AppColors.borderError,
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.textPrimary.withOpacity(0.1),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isCurrentPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // New Password Field
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_isNewPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: AppColors.borderFocused,
                      width: 2.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: AppColors.borderError,
                      width: 2.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: AppColors.borderError,
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.textPrimary.withOpacity(0.1),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: AppColors.borderFocused,
                      width: 2.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: AppColors.borderError,
                      width: 2.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: AppColors.borderError,
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.textPrimary.withOpacity(0.1),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Change Password Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CustomAnimatedButton(
                  text: 'Change Password',
                  onPressed: _changePassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
