import 'package:flutter/material.dart';
import '../models/getsubmittedmodel.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../util/app_colors.dart';
import '../util/responsive_text.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_drawer.dart';
import '../screens/reels/reels_page.dart';

class AuditionGridScreen extends StatefulWidget {
  final int? movieId;
  final String? roleType;
  final String? movieTitle;
  final String? statusFilter; // Add statusFilter parameter

  const AuditionGridScreen({
    super.key,
    required this.movieId,
    required this.roleType,
    this.movieTitle,
    this.statusFilter, // Add statusFilter to constructor
  });

  @override
  State<AuditionGridScreen> createState() => _AuditionGridScreenState();
}

class _AuditionGridScreenState extends State<AuditionGridScreen> {
  List<Data>? _auditions;
  List<Data>? _filteredAuditions;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuditions();
  }

  Future<void> _loadAuditions() async {
    if (widget.movieId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final sessionManager = SessionManager();
      final token = sessionManager.authToken;
      final response = await ApiService.getMovieAuditions(
        movieId: widget.movieId!,
        token: token,
      );

      if (response != null && response.success == true) {
        setState(() {
          _auditions = response.data;
          // Filter auditions by role type
          var filtered = _auditions
              ?.where((audition) => audition.role == widget.roleType)
              .toList();
          
          // Further filter by status if provided
          if (widget.statusFilter != null && widget.statusFilter!.isNotEmpty) {
            filtered = filtered
                ?.where((audition) => audition.status == widget.statusFilter)
                .toList();
          }
          
          _filteredAuditions = filtered;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load auditions',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error loading auditions',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _playVideo(int index) {
    if (_filteredAuditions == null || _filteredAuditions!.isEmpty) return;

    // Navigate to reels page with the selected video index and filtered auditions
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReelsPage(
          movieId: widget.movieId,
          initialIndex: index,
          roleFilter: widget.roleType,
        ),
      ),
    ).then((_) {
      // Refresh auditions when returning from ReelsPage
      // This ensures viewed videos are removed from pending list
      _loadAuditions();
    });
  }

  Widget _buildVideoThumbnail(Data audition, int index) {
    return GestureDetector(
      onTap: () => _playVideo(index),
      child: Card(
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Thumbnail Area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12.0),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Video icon as placeholder
                    Icon(
                      Icons.play_circle_outline,
                      size: ResponsiveText.iconSize(context, 48),
                      color: Colors.white70,
                    ),
                    // Status badge
                    if (audition.status != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(audition.status!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            audition.status!,
                            style: ResponsiveText.textStyle(
                              context,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    // Play button overlay
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.videocam,
                          size: ResponsiveText.iconSize(context, 16),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Audition Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Name
                  if (audition.movie?.title != null)
                    Text(
                      audition.movie!.title!,
                      style: ResponsiveText.textStyle(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (audition.movie?.title != null)
                    const SizedBox(height: 2),
                  // Role
                  if (audition.role != null)
                    Text(
                      audition.role!,
                      style: ResponsiveText.textStyle(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  // Applicant Name
                  Text(
                    audition.applicantName ?? 'Unknown',
                    style: ResponsiveText.textStyle(
                      context,
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // User Info (if available)
                  if (audition.user != null)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            audition.user!.name ?? '',
                            style: ResponsiveText.textStyle(
                              context,
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'viewed':
        return Colors.blue;
      case 'shortlisted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: widget.roleType ?? 'Auditions',
      ),
      endDrawer: const CustomDrawer(),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auditions for ${widget.roleType ?? 'this role'}',
              style: ResponsiveText.textStyle(
                context,
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.movieTitle != null) ...[
              const SizedBox(height: 4),
              Text(
                'Movie: ${widget.movieTitle}',
                style: ResponsiveText.textStyle(
                  context,
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_filteredAuditions == null || _filteredAuditions!.isEmpty)
                      ? Center(
                          child: Text(
                            'No auditions available for this role.',
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
                            childAspectRatio: ResponsiveText.isTablet(context) ? 0.7 : 0.75,
                          ),
                          itemCount: _filteredAuditions!.length,
                          itemBuilder: (context, index) {
                            final audition = _filteredAuditions![index];
                            return _buildVideoThumbnail(audition, index);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}