import 'package:flutter/material.dart';
import '../util/app_colors.dart';
import '../services/session_manager.dart';
import '../models/role.dart' as role_model;

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final List<Widget>? actions;

  const CustomHeader({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.actions,
  });

  // Function to handle logo tap based on user role
  void _handleLogoTap(BuildContext context) async {
    final sessionManager = SessionManager();
    final userRoleId = sessionManager.userRoleId;
    
    // Navigate based on user role
    if (userRoleId == role_model.Role.castingDirector) {
      // Navigate to profile screen for casting directors
      Navigator.pushNamed(context, '/profile');
    } else if (userRoleId == role_model.Role.actor) {
      // Navigate to my auditions screen for actors
      Navigator.pushNamed(context, '/my-auditions');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> allActions = [
      IconButton(
        icon: const Icon(
          Icons.menu,
          color: AppColors.textPrimary,
        ),
        onPressed: onMenuPressed ?? () => Scaffold.of(context).openEndDrawer(),
      ),
    ];

    // Add additional actions if provided
    if (actions != null) {
      allActions.insertAll(0, actions!);
    }

    return AppBar(
      backgroundColor: AppColors.primary,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: InkWell(
          onTap: () => _handleLogoTap(context), // Add tap handler
          child: SizedBox(
            width: 50,
            height: 50,
            child: Image.asset('assets/logo.png'),
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
        ),
      ),
      actions: allActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}