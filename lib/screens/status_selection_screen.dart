import 'package:flutter/material.dart';
import '../util/app_colors.dart';
import '../util/responsive_text.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_drawer.dart';

class StatusSelectionScreen extends StatelessWidget {
  final int? movieId;
  final String? roleType;
  final String? movieTitle;

  const StatusSelectionScreen({
    super.key,
    required this.movieId,
    required this.roleType,
    required this.movieTitle,
  });

  @override
  Widget build(BuildContext context) {
    // Define available statuses
    final List<Map<String, dynamic>> statuses = [
      {
        'name': 'Pending',
        'value': 'pending',
        'color': Colors.white,
        'icon': Icons.hourglass_empty,
      },
      {
        'name': 'Viewed',
        'value': 'viewed',
        'color': Colors.white,
        'icon': Icons.visibility,
      },
      {
        'name': 'Shortlisted',
        'value': 'shortlisted',
        'color': Colors.white,
        'icon': Icons.check_circle,
      },
      {
        'name': 'Rejected',
        'value': 'rejected',
        'color': Colors.white,
        'icon': Icons.cancel,
      },
    ];

    return Scaffold(
      appBar: CustomHeader(
        title: 'Select Status',
      ),
      endDrawer: const CustomDrawer(),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select status for $roleType auditions',
              style: ResponsiveText.textStyle(
                context,
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (movieTitle != null) ...[
              const SizedBox(height: 4),
              Text(
                'Movie: $movieTitle',
                style: ResponsiveText.textStyle(
                  context,
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
            const SizedBox(height: 30),
            Text(
              'Choose a status to filter auditions:',
              style: ResponsiveText.textStyle(
                context,
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: ResponsiveText.isTablet(context) ? 1.1 : 1.2,
                ),
                itemCount: statuses.length,
                itemBuilder: (context, index) {
                  final status = statuses[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to audition grid screen with status filter
                      Navigator.pushNamed(
                        context,
                        '/audition-grid',
                        arguments: {
                          'movieId': movieId,
                          'roleType': roleType,
                          'movieTitle': movieTitle,
                          'statusFilter': status['value'],
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              status['icon'],
                              size: ResponsiveText.iconSize(context, 40),
                              color: status['color'],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              status['name'],
                              style: ResponsiveText.textStyle(
                                context,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: status['color'],
                              ),
                              textAlign: TextAlign.center,
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