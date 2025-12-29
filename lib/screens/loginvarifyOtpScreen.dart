import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../util/custombutton.dart';
import '../util/app_colors.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';

class loginvarifyOtpScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final int roleId;
  final String tempToken; // Add tempToken parameter

  const loginvarifyOtpScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.roleId,
    required this.tempToken, // Add tempToken to constructor
  });

  @override
  State<loginvarifyOtpScreen> createState() => _loginvarifyOtpScreenState();
}

class _loginvarifyOtpScreenState extends State<loginvarifyOtpScreen> {
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
        final result = await ApiService.verifyRegistrationOtp(
          email: widget.email,
          otp: _otpController.text,
          tempToken: widget.tempToken, // Pass the temp token
        );

        setState(() {
          _isLoading = false;
        });

        if (result != null && result.success == true) {
          // Save session data if token is provided
          if (result.data?.accessToken != null && result.data?.user != null) {
            await SessionManager().saveSession(
              token: result.data!.accessToken!, // Use accessToken from verify OTP response
              name: result.data!.user!.name ?? '',
              email: result.data!.user!.email ?? '',
              userId: result.data!.user!.id ?? 0,
              roleId: result.data!.user!.roleId ?? 3, // Save role ID, default to Actor (3) if not provided
            );

            // Print token to console
            print('OTP Verification Successful - Token: ${result.data!.accessToken!}');

            // Navigate to profile screen
            Navigator.pushReplacementNamed(context, '/profile');
          } else {
            // Show success message and navigate to login
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('OTP verification successful! Please login.',
                      style: TextStyle(color: Colors.black)), // Black text
                  backgroundColor: Colors.white), // White background
            );

            // Navigate back to login screen
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
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
        color: AppColors.cardBackground, // Using cardBackground instead of fieldBackground
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border, // Using border instead of borderDefault
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
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Enter the 6-digit code sent to ${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 30),

                // OTP Input
                Directionality(
                  // Specify direction if needed, otherwise defaults to ltr
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
                        color: AppColors.cardBackground, // Using cardBackground instead of fieldBackground
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
                      final result = await ApiService.sendRegistrationOtp(
                        name: widget.name,
                        email: widget.email,
                        password: widget.password,
                        passwordConfirmation: widget.passwordConfirmation,
                        roleId: widget.roleId,
                      );
                      
                      if (result != null && result.success == true) {
                        // Save the new temp token
                        // Note: In a real implementation, you might want to update the widget's tempToken
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
                  child: const Text(
                    'Didn\'t receive the code? Resend OTP',
                    style: TextStyle(
                      color: AppColors.borderFocused,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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