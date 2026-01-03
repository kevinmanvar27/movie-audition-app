import 'package:flutter/material.dart';
import '../models/getmoviemodel.dart';
import '../util/app_colors.dart';
import '../util/responsive_text.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_drawer.dart';

class RolesCardScreen extends StatelessWidget {
  final int? movieId;
  final String? movieTitle;
  final List<Roles>? roles;

  const RolesCardScreen({
    super.key,
    required this.movieId,
    required this.movieTitle,
    required this.roles,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: movieTitle ?? 'Movie Roles',
      ),
      endDrawer: const CustomDrawer(),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a role to view auditions:',
              style: ResponsiveText.textStyle(
                context,
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: (roles == null || roles!.isEmpty)
                  ? Center(
                      child: Text(
                        'No roles available for this movie.',
                        style: ResponsiveText.textStyle(
                          context,
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        // Increased childAspectRatio to give more height and prevent overflow
                        childAspectRatio: ResponsiveText.isTablet(context) ? 0.75 : 0.8,
                      ),
                      itemCount: roles!.length,
                      itemBuilder: (context, index) {
                        final role = roles![index];
                        return GestureDetector(
                          onTap: () {
                            // Navigate to status selection screen with role information
                            Navigator.pushNamed(
                              context,
                              '/status-selection',
                              arguments: {
                                'movieId': movieId,
                                'roleType': role.roleType,
                                'movieTitle': movieTitle,
                              },
                            );
                          },
                          child: Card(
                            color: AppColors.cardBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Role Icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: ResponsiveText.iconSize(context, 28),
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Role Type
                                  Flexible(
                                    child: Text(
                                      role.roleType ?? 'Unknown Role',
                                      style: ResponsiveText.textStyle(
                                        context,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Gender
                                  if (role.gender != null && role.gender!.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.wc,
                                          size: ResponsiveText.iconSize(context, 12),
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            role.gender!,
                                            style: ResponsiveText.textStyle(
                                              context,
                                              fontSize: 11,
                                              color: Colors.white70,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 2),
                                  // Age Range
                                  if (role.ageRange != null && role.ageRange!.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: ResponsiveText.iconSize(context, 12),
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            role.ageRange!,
                                            style: ResponsiveText.textStyle(
                                              context,
                                              fontSize: 11,
                                              color: Colors.white70,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const Spacer(),
                                  // View Auditions indicator
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.video_library,
                                          size: ResponsiveText.iconSize(context, 12),
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'View Auditions',
                                          style: ResponsiveText.textStyle(
                                            context,
                                            fontSize: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
