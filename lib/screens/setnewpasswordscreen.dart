import 'package:flutter/material.dart';
import 'package:movie_audition/services/api_service.dart';
// import 'package:movie_audition/services/session_manager.dart'; // SessionManager ni have jarur nathi

// ignore: unused_import - kept for potential custom text form field usage
import '../util/customTextformfield.dart';
import '../util/custombutton.dart';
import '../util/app_colors.dart';
import '../util/responsive_text.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String token;
  final String email;

  const SetNewPasswordScreen({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true; // For password visibility toggle
  bool _obscureConfirmPassword = true; // For confirm password visibility toggle

  // Validation functions
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // --- CHANGES START ---
        // SessionManager ni jagya e direct widget.token no use karvo
        String resetToken = widget.token;

        // Debugging mate print statement (optional)
        print("Using Token for Reset: $resetToken");

        if (resetToken.isEmpty) {
          throw Exception("Reset token is invalid or missing.");
        }

        final result = await ApiService.resetPassword(
          resetToken: resetToken,
          email: widget.email,
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );
        // --- CHANGES END ---

        setState(() {
          _isLoading = false;
        });

        if (result != null && result.success == true) {
          // Have clearResetToken() ni jarur nathi karan ke apan store nathi karyu

          // Show success message and navigate to login screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Password reset successfully!',
                    style: TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );

          // Navigate to login screen
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        } else {
          // Show error message
          String errorMessage = result?.message ?? 'Failed to reset password. Please try again.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(errorMessage,
                    style: const TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        // Error print karo
        print("Error: $e");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Image.asset('assets/logo.png'),
                ),

                const SizedBox(height: 30),

                // Welcome Text
                Text(
                  'Set New Password',
                  style: ResponsiveText.textStyle(
                    context,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                // Email display
                Text(
                  'For account: ${widget.email}',
                  style: ResponsiveText.textStyle(
                    context,
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                Text(
                  'Please enter your new password',
                  style: ResponsiveText.textStyle(
                    context,
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Password Field with visibility toggle
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),

                const SizedBox(height: 20),

                // Confirm Password Field with visibility toggle
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: _toggleConfirmPasswordVisibility,
                    ),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),

                const SizedBox(height: 30),

                // Reset Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomAnimatedButton(
                  text: 'Reset Password',
                  onPressed: _handleResetPassword,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
