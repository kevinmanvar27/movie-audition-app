import 'package:flutter/material.dart';
import 'package:movie_audition/services/session_manager.dart';
import '../util/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 1));
    
    final sessionManager = SessionManager();
    if (sessionManager.isLoggedIn) {
      // User is logged in, navigate to profile screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    } else {
      // User is not logged in, navigate to login screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            SizedBox(
              width: 120,
              height: 120,

              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if logo.png doesn't exist
                  return const Icon(
                    Icons.movie,
                    size: 80,
                    color: Colors.white,
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
}