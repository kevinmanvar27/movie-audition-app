// actorprofile.dart
import 'package:flutter/material.dart';
import '../util/app_colors.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_drawer.dart';
import '../models/getsubmittedmodel.dart';
import '../models/getprofilemodel.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';

class ActorProfileScreen extends StatefulWidget {
  final User actor;
  final int? movieId; // Add optional movieId parameter

  const ActorProfileScreen({super.key, required this.actor, this.movieId});

  @override
  State<ActorProfileScreen> createState() => _ActorProfileScreenState();
}

class _ActorProfileScreenState extends State<ActorProfileScreen> {
  bool _isLoading = true;
  ProfileData? _profileData;
  Data? _auditionData; // Add this to store audition data
  String? _errorMessage;
  List<String>? _galleryData; // Add this to store gallery data from audition

  @override
  void initState() {
    super.initState();
    print('ActorProfileScreen initialized with actor: ${widget.actor.toJson()}');
    // Check if actor already has gallery data
    if (widget.actor.imageGallery != null && widget.actor.imageGallery is List) {
      // Process gallery URLs to ensure they are full URLs
      List<String> processedGallery = [];
      for (var item in widget.actor.imageGallery as List) {
        String? url = item?.toString();
        if (url != null && url.isNotEmpty) {
          // Unescape the URL (remove extra backslashes)
          url = url.replaceAll(r'\/', '/');
          // Normalize multiple slashes
          url = url.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
          // If it's a relative path, prepend the base URL
          if (!url.startsWith('http')) {
            // Make sure we don't duplicate '/storage/' in the path
            if (url.startsWith('/storage/')) {
              url = 'https://movieaudition.rektech.work$url';
            } else {
              url = 'https://movieaudition.rektech.work/storage/$url';
            }
          }
          // Ensure the URL starts with https
          if (url.startsWith('http://')) {
            url = url.replaceFirst('http://', 'https://');
          }
          processedGallery.add(url);
        }
      }
      _galleryData = processedGallery;
      print('Using gallery data from actor: $_galleryData');
    }
    _loadActorProfile();
  }

  Future<void> _loadActorProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _auditionData = null; // Reset audition data on load
    });

    try {
      final sessionManager = SessionManager();
      final token = sessionManager.authToken;

      // 1. Get user profile data (existing functionality)
      final profileResponse = await ApiService.getProfileData(
        token: token,
      );

      print('Profile response received');
      print('Profile response: ${profileResponse?.toJson()}');
      print('Image gallery from profile: ${profileResponse?.data?.imageGallery}');
      print('Image gallery length: ${profileResponse?.data?.imageGallery.length}');

      if (profileResponse != null && profileResponse.success == true && profileResponse.data != null) {
        setState(() {
          _profileData = profileResponse.data;
        });
        print('Profile data set. Gallery images: ${_profileData?.imageGallery}');
        print('Gallery images length: ${_profileData?.imageGallery.length}');
        
        // If profile data doesn't have gallery images but we have them from the audition, use them
        if ((_profileData?.imageGallery.isEmpty ?? true) && _galleryData != null && _galleryData!.isNotEmpty) {
          print('Using gallery data from audition instead of profile');
          setState(() {
            _profileData = ProfileData(
              id: _profileData?.id,
              name: _profileData?.name,
              email: _profileData?.email,
              emailVerifiedAt: _profileData?.emailVerifiedAt,
              createdAt: _profileData?.createdAt,
              updatedAt: _profileData?.updatedAt,
              role: _profileData?.role,
              roleId: _profileData?.roleId,
              status: _profileData?.status,
              mobileNumber: _profileData?.mobileNumber,
              profilePhoto: _profileData?.profilePhoto,
              imageGallery: _galleryData!,
              dateOfBirth: _profileData?.dateOfBirth,
              gender: _profileData?.gender,
              location: _profileData?.location,
              otpExpiresAt: _profileData?.otpExpiresAt,
              isVerified: _profileData?.isVerified,
              deviceToken: _profileData?.deviceToken,
            );
          });
        }
      } else {
        setState(() {
          _errorMessage = profileResponse?.message ?? 'Failed to load actor profile';
          _isLoading = false;
          return;
        });
      }

      // 2. NEW: Get audition data for this actor in the specific movie
      if (widget.movieId != null) { // Only fetch auditions if movieId is provided
        final auditionResponse = await ApiService.getMovieAuditions(
          movieId: widget.movieId!, // Use the provided movieId
          token: token,
        );

        if (auditionResponse != null && auditionResponse.success == true && auditionResponse.data != null) {
          // Find the audition for this specific actor
          Data? foundAudition;
          for (var audition in auditionResponse.data!) {
            if (audition.userId == widget.actor.id) {
              foundAudition = audition;
              break;
            }
          }

          setState(() {
            _auditionData = foundAudition; // Will be null if not found
          });
          print('Audition data set. Actor gallery: ${foundAudition?.user?.imageGallery}');
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _errorMessage = 'Error loading profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building ActorProfileScreen');
    print('_isLoading: $_isLoading');
    print('_errorMessage: $_errorMessage');
    print('_profileData: ${_profileData != null}');
    if (_profileData != null) {
      print('_profileData.imageGallery: ${_profileData!.imageGallery}');
      print('_profileData.imageGallery.length: ${_profileData!.imageGallery.length}');
    }
    
    return Scaffold(
      appBar: const CustomHeader(
        title: 'Actor Profile',
      ),
      endDrawer: const CustomDrawer(),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
        ),
      )
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadActorProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Profile Picture
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _profileData?.profilePhoto != null && _profileData!.profilePhoto!.isNotEmpty
                      ? Image.network(
                    _profileData!.profilePhoto!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.textSecondary,
                      );
                    },
                  )
                      : const Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Actor Name
            Text(
              _profileData?.name ?? widget.actor.name ?? 'Unknown Actor',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Profile Details Card
            Card(
              color: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildDetailRow(Icons.email, 'Email', _profileData?.email ?? 'N/A'),
                    const SizedBox(height: 15),
                    _buildDetailRow(Icons.wc, 'Gender', _profileData?.gender ?? 'N/A'),
                    const SizedBox(height: 15),
                    _buildDetailRow(Icons.cake, 'Date of Birth', _profileData?.dateOfBirth ?? 'N/A'),
                    const SizedBox(height: 15),
                    _buildDetailRow(Icons.phone, 'Phone Number', _profileData?.mobileNumber ?? 'N/A'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Audition Information Card (NEW)
            // Only show this card if a valid audition was found for this actor/movie
            // Image Gallery Section
            if (_profileData?.imageGallery != null)
              Card(
                color: AppColors.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gallery',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Display image gallery in a grid with full-screen view on click
                      if (_profileData!.imageGallery.isNotEmpty)
                        SizedBox(
                          height: 200, // Fixed height for the grid
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _profileData!.imageGallery.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  // Show full-screen image viewer
                                  _showFullScreenImage(_profileData!.imageGallery, index);
                                },
                                child: Hero(
                                  tag: 'gallery_image_$index',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _profileData!.imageGallery[index],
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: AppColors.background,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        print('Error loading image at index $index: $error');
                                        return Container(
                                          color: AppColors.background,
                                          child: const Icon(
                                            Icons.broken_image,
                                            color: AppColors.textSecondary,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No gallery images available',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.secondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(List<String> images, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black54,
            foregroundColor: Colors.white,
            title: Text('Image ${index + 1} of ${images.length}'),
          ),
          body: GestureDetector(
            child: Center(
              child: Hero(
                tag: 'gallery_image_$index',
                child: InteractiveViewer(
                  child: Image.network(
                    images[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.white70,
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}