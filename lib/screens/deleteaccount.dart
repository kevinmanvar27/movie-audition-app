import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../util/app_colors.dart';
import '../util/responsive_text.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart'; // Added import for custom header

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isLoading = false;
  final SessionManager _sessionManager = SessionManager();
  final TextEditingController _passwordController = TextEditingController();

  // Modified function to delete account without dialog
  void _deleteAccount() async {
    if (_passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = _sessionManager.authToken;

      if (token == null) {
        if (mounted) {
          Fluttertoast.showToast(msg: 'Authentication error. Please log in again.');
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Call API to delete account with password
      final response = await ApiService.deleteAccount(
        password: _passwordController.text,
        token: token,
      );

      setState(() {
        _isLoading = false;
      });

      if (response != null) {
        if (response.success == true) {
          // Account deleted successfully
          if (mounted) {
            Fluttertoast.showToast(msg: response.message ?? 'Account deleted successfully!');

            // Clear session data
            await _sessionManager.clearSession();

            // Navigate to login screen
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        } else {
          // Show error message
          String errorMessage;

          // Check for validation errors first
          if (response.hasValidationErrors) {
            errorMessage = response.validationError ?? 'Invalid password. Please try again.';
          } else {
            errorMessage = response.message ?? 'Failed to delete account. Please try again.';
          }

          if (mounted) {
            Fluttertoast.showToast(msg: errorMessage);
          }
        }
      } else {
        if (mounted) {
          Fluttertoast.showToast(msg: 'Network error. Please check your connection and try again.');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Fluttertoast.showToast(msg: 'An error occurred. Please try again.');
        print('Delete account error: $e');
      }
    } finally {
      _passwordController.clear();
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: 'Delete Account',
      ),
      endDrawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete Your Account',
                style: ResponsiveText.textStyle(
                  context,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Warning: This action is irreversible!',
                style: ResponsiveText.textStyle(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'By deleting your account, you will:',
                style: ResponsiveText.textStyle(
                  context,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const BulletPoint(text: 'Permanently lose access to your account'),
              const BulletPoint(text: 'Lose all your profile data'),
              const BulletPoint(text: 'Lose all your audition submissions'),
              const BulletPoint(text: 'Lose all your movie listings (if you are a casting director)'),
              const SizedBox(height: 30),
              Text(
                'This action cannot be undone. Please make sure you want to delete your account before proceeding.',
                style: ResponsiveText.textStyle(
                  context,
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 30),
              // Password input field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter your password to confirm',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // OK button
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _deleteAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'OK',
                          style: ResponsiveText.textStyle(
                            context,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: ResponsiveText.textStyle(
              context,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: ResponsiveText.textStyle(
                context,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}