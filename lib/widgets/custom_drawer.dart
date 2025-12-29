import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import '../util/app_colors.dart';
import 'drawer_header.dart'; // Import the custom drawer header

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late SessionManager sessionManager;

  @override
  void initState() {
    super.initState();
    sessionManager = SessionManager();
  }

  void _handleLogout() async {
    try {
      // Call API to logout (optional)
      final token = sessionManager.authToken;
      if (token != null) {
        // You can call ApiService.logoutUser(token) here if needed
      }
      
      // Clear session data
      await sessionManager.clearSession();
      
      // Navigate to login screen
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to logout. Please try again.',
                style: TextStyle(color: Colors.black)), // Black text
            backgroundColor: Colors.white), // White background
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.scaffoldBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Use the custom drawer header
          const UserDrawerHeader(),
          
          const SizedBox(height: 20),
          
          // Profile Section
          ListTile(
            leading: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          
          // Edit Profile Section
          ListTile(
            leading: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            title: const Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            onTap: () {
              // Close the drawer first
              Navigator.pop(context);
              // Navigate to edit profile screen
              Navigator.pushNamed(context, '/edit-profile');
            },
          ),
          
          // Show "My Auditions" only for Actors (role ID 3)
          if (sessionManager.userRoleId == 3)
            ListTile(
              leading: const Icon(
                Icons.video_collection,
                color: Colors.white,
              ),
              title: const Text(
                'My Auditions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/my-auditions');
              },
            ),
          
          // Show "Add Movie" only for Casting Directors (role ID 2)
          if (sessionManager.userRoleId == 2)
            ListTile(
              leading: const Icon(
                Icons.add_box,
                color: Colors.white,
              ),
              title: const Text(
                'Add Movie',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/add-movie');
              },
            ),
          
          // Show "Movies" only for Actors (role ID 3, NOT for Casting Directors)
          if (sessionManager.userRoleId == 3)
            ListTile(
              leading: const Icon(
                Icons.movie,
                color: Colors.white,
              ),
              title: const Text(
                'Movies',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/movies');
              },
            ),
          
          // Change Password Section
          ListTile(
            leading: const Icon(
              Icons.lock,
              color: Colors.white,
            ),
            title: const Text(
              'Change Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            onTap: () {
              // Close the drawer first
              Navigator.pop(context);
              // Navigate to change password screen
              Navigator.pushNamed(context, '/change-password');
            },
          ),
          
          const Divider(
            color: Colors.white30,
            thickness: 1,
          ),
          
          const Divider(
            color: Colors.white30,
            thickness: 1,
          ),
          
          ListTile(
            leading: const Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            title: const Text(
              'Delete Account',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            onTap: () {
              // Close the drawer first
              Navigator.pop(context);
              // Navigate to delete account screen
              Navigator.pushNamed(context, '/delete-account');
            },
          ),
          
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }
}