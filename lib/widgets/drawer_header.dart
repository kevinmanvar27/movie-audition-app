import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import '../services/api_service.dart';
import '../models/getprofilemodel.dart';
import '../util/app_colors.dart';

class UserDrawerHeader extends StatefulWidget {
  const UserDrawerHeader({super.key});

  @override
  State<UserDrawerHeader> createState() => _UserDrawerHeaderState();
}

class _UserDrawerHeaderState extends State<UserDrawerHeader> {
  GetProfileModel? _profileData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final sessionManager = SessionManager();
      final token = sessionManager.authToken;
      
      if (token != null) {
        final profileResponse = await ApiService.getProfileData(token: token);
        
        if (mounted) {
          setState(() {
            _profileData = profileResponse;
            _isLoading = false;
            _hasError = profileResponse == null || profileResponse.success != true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionManager();
    
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isLoading)
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.secondary,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            else if (_hasError)
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.secondary,
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: AppColors.textPrimary,
                ),
              )
            else if (_profileData?.data?.profilePhoto != null && 
                     _profileData!.data!.profilePhoto!.isNotEmpty)
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.secondary,
                backgroundImage: NetworkImage(
                  _profileData!.data!.profilePhoto!,
                ),
              )
            else
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.secondary,
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: AppColors.textPrimary,
                ),
              ),
            const SizedBox(height: 12),
            
            // User name
            Text(
              _profileData?.data?.name ?? sessionManager.userName ?? 'User Name',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // User email
            Text(
              _profileData?.data?.email ?? sessionManager.userEmail ?? 'user@example.com',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}