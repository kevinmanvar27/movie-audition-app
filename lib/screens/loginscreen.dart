// Login Screen
import 'package:flutter/material.dart';
import 'package:movie_audition/services/api_service.dart';

import '../util/customTextformfield.dart';
import '../util/custombutton.dart';
import '../util/app_colors.dart';
import '../util/responsive_text.dart';
import '../services/session_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true; // For password visibility toggle

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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final result = await ApiService.loginUser(
          email: _emailController.text,
          password: _passwordController.text,
        );
        
        setState(() {
          _isLoading = false;
        });
        
        if (result != null && result.success == true) {
          // Save session data
          if (result.data?.token != null && result.data?.user != null) {
            await SessionManager().saveSession(
              token: result.data!.token ?? '',
              name: result.data!.user!.name ?? '',
              email: result.data!.user!.email ?? '',
              userId: result.data!.user!.id ?? 0,
              roleId: result.data!.user!.roleId ?? 0, // Save role ID with null check
            );
            
            // Print token to console
            print('Login Successful - Token: ${result.data!.token ?? ''}');
          }
          
          // Login successful, show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Login successful!',
                    style: TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
          Navigator.pushReplacementNamed(context, '/profile');
        } else {
          // Show error message
          String errorMessage = result?.message ?? 'Login failed. Please check your credentials.';
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
        
        String errorMessage = 'An error occurred. Please try again.';
        
        // Check if the exception is a network error
        if (e.toString().contains('SocketException') || e.toString().contains('Network error')) {
          errorMessage = 'Network error. Please check your internet connection and try again.';
        } else if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
          errorMessage = 'Request timeout. Server is not responding. Please try again later.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(errorMessage,
                  style: const TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                
                const SizedBox(height: 40),
                
                // Welcome Text
                Text(
                  'Welcome Back!',
                  style: ResponsiveText.textStyle(
                    context,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                Text(
                  'Sign in to continue',
                  style: ResponsiveText.textStyle(
                    context,
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Email Field
                CustomTextField(
                  labelText: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                
                const SizedBox(height: 20),
                
                // Password Field with visibility toggle
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                
                const SizedBox(height: 40),
                
                // Login Button
                _isLoading 
                  ? const CircularProgressIndicator()
                  : CustomAnimatedButton(
                      text: 'Login',
                      onPressed: _handleLogin,
                    ),
                
                const SizedBox(height: 20),
                
                // Forgot Password Link
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: ResponsiveText.textStyle(
                        context,
                        fontSize: 16,
                        color: AppColors.borderFocused,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: ResponsiveText.textStyle(
                        context,
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        'Register',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}