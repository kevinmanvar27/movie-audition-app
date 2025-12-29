import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_drawer.dart';
import '../util/app_colors.dart';
import '../util/custombutton.dart'; // This imports CustomAnimatedButton
import '../models/role.dart';
import '../services/session_manager.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  int? _selectedRoleId;

  void _selectRole(int roleId) {
    setState(() {
      _selectedRoleId = roleId;
    });
  }

  void _saveRoleAndNavigate() async {
    if (_selectedRoleId != null) {
      // Save role to session
      final sessionManager = SessionManager();
      // Get existing user data
      final token = sessionManager.authToken;
      final name = sessionManager.userName;
      final email = sessionManager.userEmail;
      final userId = sessionManager.userId;
      final profilePhoto = sessionManager.userProfilePhoto;
      
      // Save all user data including the new role ID
      if (token != null && name != null && email != null && userId != null) {
        await sessionManager.saveSession(
          token: token,
          name: name,
          email: email,
          userId: userId,
          profilePhoto: profilePhoto,
          roleId: _selectedRoleId,
        );
      }
      
      // Navigate to appropriate screen based on role
      if (mounted) {
        if (_selectedRoleId == 2) { // Casting Director
          // For Casting Directors, navigate to profile screen (not movies screen directly)
          Navigator.pushReplacementNamed(context, '/profile');
        } else {
          // For Actors (or any other role), navigate to profile screen
          Navigator.pushReplacementNamed(context, '/profile');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(
        title: 'Select Your Role',
      ),
      endDrawer: const CustomDrawer(),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Please select your role to continue',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            // Actor Role Card
            GestureDetector(
              onTap: () => _selectRole(3), // Actor role ID (consistent with Role.model)
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedRoleId == 3 
                      ? AppColors.primary.withOpacity(0.3) 
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedRoleId == 3 
                        ? AppColors.primary 
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.person,
                      size: 60,
                      color: _selectedRoleId == 3 
                          ? AppColors.primary 
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Actor',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Browse movies, apply for auditions, and manage your applications',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Casting Director Role Card
            GestureDetector(
              onTap: () => _selectRole(2), // Casting Director role ID (consistent with Role.model)
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedRoleId == 5 
                      ? AppColors.primary.withOpacity(0.3) 
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedRoleId == 2 
                        ? AppColors.primary 
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.movie,
                      size: 60,
                      color: _selectedRoleId == 2 
                          ? AppColors.primary 
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Casting Director',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create and manage movie auditions, review applications',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            CustomAnimatedButton( // Use CustomAnimatedButton instead of CustomButton
              text: 'Continue',
              onPressed: _selectedRoleId != null ? _saveRoleAndNavigate : () {}, // Provide empty function instead of null
            ),
          ],
        ),
      ),
    );
  }
}