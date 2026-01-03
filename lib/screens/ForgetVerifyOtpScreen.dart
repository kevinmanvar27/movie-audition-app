import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:movie_audition/services/api_service.dart';
import 'package:movie_audition/services/session_manager.dart';

import '../util/custombutton.dart';
import '../util/app_colors.dart';
import '../util/responsive_text.dart';

class ForgetVerifyOtpScreen extends StatefulWidget {
  final String email;
  final int userId;

  const ForgetVerifyOtpScreen({
    super.key,
    required this.email,
    required this.userId,
  });

  @override
  State<ForgetVerifyOtpScreen> createState() => _ForgetVerifyOtpScreenState();
}

class _ForgetVerifyOtpScreenState extends State<ForgetVerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  void _handleVerifyOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await ApiService.verifyPasswordResetOtp(
          email: widget.email,
          otp: _otpController.text,
          userId: widget.userId,
        );

        setState(() {
          _isLoading = false;
        });

        if (result != null && result.success == true) {
          //print('OTP Verification Successful. Reset Token: ${result.resetToken}');
          
          // Save reset token to shared preferences
          await SessionManager().saveResetToken(result.resetToken ?? '');
          
          // Navigate to set new password screen
          Navigator.pushNamed(
            context,
            '/set-new-password',
            arguments: {
              'resetToken': result.resetToken ?? '',
              'email': widget.email,
            },
          );
        } else {
          // Show error message
          String errorMessage = result?.message ?? 'OTP verification failed. Please try again.';
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
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
    );

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
                  'Verify Your Email',
                  style: ResponsiveText.textStyle(
                    context,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Enter the 6-digit code sent to ${widget.email}',
                  textAlign: TextAlign.center,
                  style: ResponsiveText.textStyle(
                    context,
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 30),

                // OTP Input
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    controller: _otpController,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(
                          color: AppColors.borderFocused,
                        ),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: AppColors.cardBackground,
                        border: Border.all(
                          color: AppColors.borderFocused,
                        ),
                      ),
                    ),
                    validator: _validateOtp,
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    showCursor: true,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                  ),
                ),

                const SizedBox(height: 30),

                // Verify Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomAnimatedButton(
                        text: 'Verify OTP',
                        onPressed: _handleVerifyOtp,
                      ),

                const SizedBox(height: 20),

                // Resend OTP Link
                TextButton(
                  onPressed: () async {
                    try {
                      final result = await ApiService.sendPasswordResetOtp(email: widget.email);
                      
                      if (result != null && result.success == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('OTP has been resent to your email',
                                  style: TextStyle(color: Colors.black)), // Black text
                              backgroundColor: Colors.white), // White background
                        );
                      } else {
                        String errorMessage = result?.message ?? 'Failed to resend OTP. Please try again.';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(errorMessage,
                                  style: const TextStyle(color: Colors.black)), // Black text
                              backgroundColor: Colors.white), // White background
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('An error occurred. Please try again.',
                                style: TextStyle(color: Colors.black)), // Black text
                            backgroundColor: Colors.white), // White background
                      );
                    }
                  },
                  child: Text(
                    'Didn\'t receive the code? Resend OTP',
                    style: ResponsiveText.textStyle(
                      context,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.borderFocused,
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