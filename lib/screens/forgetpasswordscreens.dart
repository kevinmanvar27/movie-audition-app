import 'package:flutter/material.dart';
import 'package:movie_audition/services/api_service.dart';

import '../util/customTextformfield.dart';
import '../util/custombutton.dart';
import '../util/app_colors.dart';
import '../util/responsive_text.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Validation functions
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Call the API to send password reset OTP
        final response = await ApiService.sendPasswordResetOtp(
          email: _emailController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (response != null && response.success == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Password reset OTP sent to your email!',
                    style: TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
          
          // Navigate to verify OTP screen with user ID
          Navigator.pushNamed(
            context,
            '/verify-otp',
            arguments: {
              'email': _emailController.text,
              'userId': response.userId ?? 0,
            },
          );
        } else {
          // Show error message
          String errorMessage = response?.message ?? 'Failed to send password reset OTP. Please try again.';
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
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred. Please try again.',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                
                // Title
                Text(
                  'Forgot Password?',
                  style: ResponsiveText.textStyle(
                    context,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                Text(
                  'Enter your email to reset your password',
                  style: ResponsiveText.textStyle(
                    context,
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 30),
                
                // Email Field
                CustomTextField(
                  labelText: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
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
                
                // Back to Login
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Back to Login',
                      style: ResponsiveText.textStyle(
                        context,
                        fontSize: 16,
                        color: AppColors.borderFocused,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}