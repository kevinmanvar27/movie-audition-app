import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import '../util/app_colors.dart';
import '../util/responsive_text.dart';
import '../services/session_manager.dart';
import '../services/api_service.dart';
import '../models/role.dart' as role_model; // Alias to avoid conflict
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import '../models/getprofilemodel.dart'; // Import profile model
// ignore: unused_import - kept for potential gallery upload model usage
import '../models/UploadGallerymodel.dart'; // Import upload gallery model
// ignore: unused_import - kept for potential gallery delete model usage
import '../models/deletegalerymodel.dart'; // Import delete gallery model
import 'dart:io'; // Import for file handling
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Import for image compression
import 'package:flutter_image_compress/flutter_image_compress.dart' show CompressFormat; // Import CompressFormat enum
// Add imports for movie functionality
import '../models/getmoviemodel.dart' as movie_model;
import '../models/editmoviemodel.dart' as edit_movie_model;
// ignore: unused_import - kept for potential movie screen navigation
import '../screens/moviescreen.dart';
// ignore: unused_import - kept for potential foundation usage
import 'package:flutter/foundation.dart'; // Add this import for RouteAware

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  
  // Add RouteObserver for listening to route changes
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  List<String> _imageUrls = []; // Store image URLs
  bool _isLoadingGallery = true; // Track gallery loading state
  bool _isLoadingProfile = true; // Track profile loading state
  final SessionManager _sessionManager = SessionManager();
  GetProfileModel? _profileData; // Store profile data
  Map<String, dynamic>? _fallbackData; // Fallback data from SessionManager
  // Add movie related variables
  List<movie_model.GetData>? _movies = [];
  bool _isLoadingMovies = true;
  String _selectedStatusFilter = 'all'; // Filter: all, active, inactive, upcoming

  @override
  void initState() {
    super.initState();
    _refreshFallbackData(); // Refresh fallback data first
    _loadProfileData(); // Then load profile data from API
    // Load movies for casting directors
    _loadMovies();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    ProfileScreen.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  // Called when the top route is removed (e.g., when returning to this screen)
  @override
  void didPopNext() {
    // Refresh data when coming back from another screen
    _refreshAllData();
  }
  
  // Called when this route is pushed onto the navigator (when navigating to this screen)
  @override
  void didPushNext() {
    // This is called when leaving this screen, no action needed
  }
  
  // Called when this route is pushed onto the navigator
  @override
  void didPush() {
    // Refresh data when navigating to this screen
    _refreshAllData();
  }

  // Refresh all data
  void _refreshAllData() {
    _refreshFallbackData();
    _loadProfileData();
    _loadMovies();
  }

  // Load profile data and gallery images for the user
  void _loadProfileData() async {
    setState(() {
      _isLoadingGallery = true;
      _isLoadingProfile = true;
    });

    try {
      final token = _sessionManager.authToken;
      if (token == null) {
        if (mounted) {
          Fluttertoast.showToast(msg: 'Authentication error. Please log in again.');
        }
        setState(() {
          _isLoadingGallery = false;
          _isLoadingProfile = false;
        });
        return;
      }

      // Fetch updated profile data which includes gallery images
      final profileResponse = await ApiService.getProfileData(token: token);

      if (profileResponse != null && profileResponse.success == true) {
        setState(() {
          _profileData = profileResponse;
          // Use actual gallery images from API response
          _imageUrls = profileResponse.data?.imageGallery ?? [];
          _isLoadingGallery = false;
          _isLoadingProfile = false;
        });
      } else {
        setState(() {
          _profileData = null;
          _imageUrls = [];
          _isLoadingGallery = false;
          _isLoadingProfile = false;
        });
        if (mounted) {
          Fluttertoast.showToast(msg: 'Failed to load profile data from API');
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingGallery = false;
        _isLoadingProfile = false;
      });
      if (mounted) {
        Fluttertoast.showToast(msg: 'Failed to load profile data: $e');
      }
    }
  }

  // Load movies for casting directors
  void _loadMovies() async {
    final userRoleId = _sessionManager.userRoleId;
    
    // Only load movies for casting directors (role ID 2)
    if (userRoleId != 2) {
      setState(() {
        _isLoadingMovies = false;
      });
      return;
    }
    
    setState(() {
      _isLoadingMovies = true;
    });

    try {
      final token = _sessionManager.authToken;
      if (token == null) {
        if (mounted) {
          Fluttertoast.showToast(msg: 'Authentication error. Please log in again.');
        }
        setState(() {
          _isLoadingMovies = false;
        });
        return;
      }

      // Fetch movies created by this casting director
      final moviesResponse = await ApiService.getAllMovies(token: token);
      
      if (moviesResponse != null && moviesResponse.success == true) {
        setState(() {
          _movies = moviesResponse.data;
          _isLoadingMovies = false;
        });
        print('Loaded ${_movies?.length ?? 0} movies for casting director');
        // Print details of loaded movies for debugging
        if (_movies != null) {
          for (int i = 0; i < _movies!.length; i++) {
            final movie = _movies![i];
            print('Movie $i: ID=${movie.id}, Title="${movie.title}", Roles count=${movie.roles?.length ?? 0}');
            if (movie.roles != null) {
              for (int j = 0; j < movie.roles!.length; j++) {
                final role = movie.roles![j];
                print('  Role $j: ID=${role.id}, Type="${role.roleType}", Gender="${role.gender}"');
              }
            }
          }
        }
      } else {
        setState(() {
          _movies = [];
          _isLoadingMovies = false;
        });
        if (mounted) {
          Fluttertoast.showToast(msg: 'Failed to load movies');
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingMovies = false;
      });
      if (mounted) {
        Fluttertoast.showToast(msg: 'Failed to load movies: $e');
      }
    }
  }

  // Helper method to get profile data with fallback
  String _getProfileValue(String key) {
    // Try to get from API data first
    if (_profileData?.data != null) {
      switch (key) {
        case 'name':
          return _profileData!.data!.name ?? _fallbackData?['name'] ?? 'N/A';
        case 'email':
          return _profileData!.data!.email ?? _fallbackData?['email'] ?? 'N/A';
        case 'mobileNumber':
          return _profileData!.data!.mobileNumber ?? _fallbackData?['mobileNumber'] ?? 'N/A';
        case 'location':
          return _profileData!.data!.location ?? _fallbackData?['location'] ?? 'N/A';
        case 'roleId':
          return (_profileData!.data!.roleId ?? _fallbackData?['roleId'] ?? 0).toString();
        case 'profilePhoto':
          return _profileData!.data!.profilePhoto ?? '';
      }
    }

    // Fallback to session data
    return _fallbackData?[key]?.toString() ?? 'N/A';
  }

  // Refresh fallback data
  void _refreshFallbackData() {
    setState(() {
      _fallbackData = {
        'name': _sessionManager.userName,
        'email': _sessionManager.userEmail,
        'mobileNumber': _sessionManager.userPhone,
        'roleId': _sessionManager.userRoleId,
        'location': _sessionManager.userLocation,
      };
    });
  }

  // Get filtered movies based on selected status
  List<movie_model.GetData> _getFilteredMovies() {
    if (_movies == null || _movies!.isEmpty) {
      return [];
    }
    
    if (_selectedStatusFilter == 'all') {
      return _movies!;
    }
    
    return _movies!.where((movie) {
      final status = movie.status?.toLowerCase() ?? '';
      return status == _selectedStatusFilter.toLowerCase();
    }).toList();
  }

  // Build filter chip widget
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatusFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatusFilter = value;
        });
      },
      backgroundColor: AppColors.cardBackground,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: 1,
      ),
    );
  }

  // Handle image upload
  void _uploadImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        final token = _sessionManager.authToken;
        final userId = _sessionManager.userId;

        if (token == null || userId == null) {
          if (mounted) {
            Fluttertoast.showToast(msg: 'Authentication error. Please log in again.');
          }
          return;
        }

        // Show loading indicator
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text("Processing image..."),
                  ],
                ),
              );
            },
          );
        }

        // Get the selected image file
        final imageFile = File(result.files.single.path!);

        // Compress the image to less than 2MB
        final compressedImageFile = await _compressImage(imageFile);

        if (compressedImageFile == null) {
          // Dismiss loading dialog
          if (mounted) {
            Navigator.of(context).pop();
            Fluttertoast.showToast(msg: 'Failed to process image');
          }
          return;
        }

        // Upload the compressed image to the server
        final uploadResponse = await ApiService.uploadGalleryImage(
          imageFile: compressedImageFile,
          userId: userId,
          token: token,
        );

        // Dismiss loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (uploadResponse != null && uploadResponse.success) {
          if (mounted) {
            Fluttertoast.showToast(msg: 'Image uploaded successfully!');
            // Refresh profile data to show the new image
            _loadProfileData();
          }
        } else {
          if (mounted) {
            Fluttertoast.showToast(msg: 'Failed to upload image');
          }
        }

        // Clean up temporary compressed file
        if (compressedImageFile != imageFile && compressedImageFile.existsSync()) {
          compressedImageFile.delete();
        }
      }
    } catch (e) {
      // Dismiss loading dialog if still showing
      if (mounted) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: 'Failed to upload image: $e');
      }
    }
  }

  // Compress image to less than 2MB
  Future<File?> _compressImage(File imageFile) async {
    try {
      // Get original file size
      final originalSize = await imageFile.length();
      print('Original image size: ${originalSize / (1024 * 1024)} MB');

      // If already less than 2MB, return original file
      if (originalSize <= 2 * 1024 * 1024) {
        return imageFile;
      }

      // Calculate quality based on file size to get under 2MB
      int quality = (2 * 1024 * 1024 * 100 / originalSize).round();
      if (quality > 95) quality = 95; // Cap at 95% quality
      if (quality < 10) quality = 10; // Minimum 10% quality

      // For simplicity, we'll use fixed dimensions that should keep the file under 2MB
      // Most cameras produce images that when compressed with these settings will be under 2MB
      int targetWidth = 1920;
      int targetHeight = 1080;

      // Compress the image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        '${imageFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
        quality: quality,
        minWidth: targetWidth,
        minHeight: targetHeight,
        // Added format and rotate options for better compression
        format: CompressFormat.jpeg,
        autoCorrectionAngle: true,
      );

      // Convert XFile to File
      if (compressedFile != null) {
        final File compressedImageFile = File(compressedFile.path);
        final compressedSize = await compressedImageFile.length();
        print('Compressed image size: ${compressedSize / (1024 * 1024)} MB');
        
        // Check if compression was successful and file is under 2MB
        if (compressedSize <= 2 * 1024 * 1024) {
          return compressedImageFile;
        } else {
          // If still over 2MB, try stronger compression
          final strongerCompressedFile = await FlutterImageCompress.compressAndGetFile(
            imageFile.absolute.path,
            '${imageFile.parent.path}/strong_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
            quality: 70, // Fixed lower quality
            minWidth: 1280, // Lower resolution
            minHeight: 720,
            format: CompressFormat.jpeg,
            autoCorrectionAngle: true,
          );
          
          if (strongerCompressedFile != null) {
            final strongerCompressedImageFile = File(strongerCompressedFile.path);
            final strongerCompressedSize = await strongerCompressedImageFile.length();
            print('Stronger compressed image size: ${strongerCompressedSize / (1024 * 1024)} MB');
            return strongerCompressedImageFile;
          }
        }
      }

      return null;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  // Handle image deletion
  void _deleteImage(String imageUrl) async {
    try {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Image'),
            content: const Text('Are you sure you want to delete this image?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        final token = _sessionManager.authToken;
        final userId = _sessionManager.userId;

        if (token == null || userId == null) {
          if (mounted) {
            Fluttertoast.showToast(msg: 'Authentication error. Please log in again.');
          }
          return;
        }

        // Show loading indicator
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text("Deleting image..."),
                  ],
                ),
              );
            },
          );
        }

        // Delete the image from the server
        final deleteResponse = await ApiService.deleteGalleryImage(
          userId: userId,
          imageUrl: imageUrl,
          token: token,
        );

        // Dismiss loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (deleteResponse != null && deleteResponse.success == true) {
          if (mounted) {
            Fluttertoast.showToast(msg: 'Image deleted successfully!');
            // Refresh profile data to remove the deleted image
            _loadProfileData();
          }
        } else {
          if (mounted) {
            Fluttertoast.showToast(msg: 'Failed to delete image');
          }
        }
      }
    } catch (e) {
      // Dismiss loading dialog if still showing
      if (mounted) {
        Navigator.of(context).pop();
        print('Exception during image deletion: $e');
        Fluttertoast.showToast(msg: 'Failed to delete image. Please try again.');
      }
    }
  }

  // Handle movie deletion
  void _deleteMovie(int movieId, String movieTitle) async {
    try {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Movie'),
            content: Text('Are you sure you want to delete "$movieTitle"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        final token = _sessionManager.authToken;

        if (token == null) {
          if (mounted) {
            Fluttertoast.showToast(msg: 'Authentication error. Please log in again.');
          }
          return;
        }

        // Show loading indicator
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text("Deleting movie..."),
                  ],
                ),
              );
            },
          );
        }

        // Delete the movie from the server
        final deleteResponse = await ApiService.deleteMovie(
          movieId: movieId,
          token: token,
        );

        // Dismiss loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (deleteResponse != null && deleteResponse.success == true) {
          if (mounted) {
            Fluttertoast.showToast(msg: 'Movie deleted successfully!');
            // Refresh movies list
            _loadMovies();
          }
        } else {
          if (mounted) {
            Fluttertoast.showToast(msg: 'Failed to delete movie');
          }
        }
      }
    } catch (e) {
      // Dismiss loading dialog if still showing
      if (mounted) {
        Navigator.of(context).pop();
        print('Exception during movie deletion: $e');
        Fluttertoast.showToast(msg: 'Failed to delete movie. Please try again.');
      }
    }
  }

  @override
  void dispose() {
    // Unsubscribe from route changes
    ProfileScreen.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(
        title: 'Profile',
      ),
      endDrawer: const CustomDrawer(),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: _isLoadingProfile
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _getProfileValue('profilePhoto').isNotEmpty
                          ? NetworkImage(_getProfileValue('profilePhoto'))
                          : null,
                      child: _getProfileValue('profilePhoto').isEmpty
                          ? const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey,
                      )
                          : null,
                    ),
                    const SizedBox(width: 20),
        
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getProfileValue('name'),
                            style: ResponsiveText.textStyle(
                              context,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Email ID on a single line without wrapping
                          Text(
                            _getProfileValue('email'),
                            style: ResponsiveText.textStyle(
                              context,
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Phone number - only show if available
                          if (_getProfileValue('mobileNumber') != 'N/A' && _getProfileValue('mobileNumber').isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Phone: ${_getProfileValue('mobileNumber')}',
                              style: ResponsiveText.textStyle(
                                context,
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Role: ${role_model.Role.getRoleLabel(int.tryParse(_getProfileValue('roleId')) ?? 0)}',
                                style: ResponsiveText.textStyle(
                                  context,
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          // Removed User ID display
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        
              const SizedBox(height: 30),
        
              // Show image gallery section only for actors
              // Show gallery section only for actors who have images
              if ((int.tryParse(_getProfileValue('roleId')) ?? 0) == 3 && _imageUrls.isNotEmpty) ...[
                // Actor role ID is 3
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Images',
                      style: ResponsiveText.textStyle(
                        context,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: _uploadImage,
                      child: Text(
                        'Add Picture',
                        style: ResponsiveText.textStyle(
                          context,
                          fontSize: 16,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
        
                // Image Grid - Responsive with square images
                Container(
                  constraints: const BoxConstraints(
                    minHeight: 200,
                    maxHeight: 400,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isLoadingGallery
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1, // Makes images square
                    ),
                    itemCount: _imageUrls.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _imageUrls[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
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
                                return Container(
                                  color: AppColors.primary,
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                          // Delete button overlay
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _deleteImage(_imageUrls[index]),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
        
                const SizedBox(height: 30),
              ],
              
              // Show prompt for actors with no images
              if ((int.tryParse(_getProfileValue('roleId')) ?? 0) == 3 && _imageUrls.isEmpty && !_isLoadingGallery) ...[
                Text(
                  'My Images',
                  style: ResponsiveText.textStyle(
                    context,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: ResponsiveText.iconSize(context, 64),
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No images yet',
                        style: ResponsiveText.textStyle(
                          context,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Showcase your talent by adding your portfolio images',
                        textAlign: TextAlign.center,
                        style: ResponsiveText.textStyle(
                          context,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _uploadImage,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Your First Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
              
              // Show prompt for casting directors with no movies
              if ((int.tryParse(_getProfileValue('roleId')) ?? 0) == 2 && (_movies == null || _movies!.isEmpty) && !_isLoadingMovies) ...[
                Text(
                  'My Movies',
                  style: ResponsiveText.textStyle(
                    context,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.movie_outlined,
                        size: ResponsiveText.iconSize(context, 64),
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No movies yet',
                        style: ResponsiveText.textStyle(
                          context,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start your casting journey by adding your first movie project',
                        textAlign: TextAlign.center,
                        style: ResponsiveText.textStyle(
                          context,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add-movie');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Your First Movie'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
              
              // Show movies section only for casting directors who have movies
              if ((int.tryParse(_getProfileValue('roleId')) ?? 0) == 2 && _movies != null && _movies!.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Movies',
                      style: ResponsiveText.textStyle(
                        context,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add-movie');
                      },
                      child: Text(
                        'Add Movie',
                        style: ResponsiveText.textStyle(
                          context,
                          fontSize: 16,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active', 'active'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Inactive', 'inactive'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Upcoming', 'upcoming'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
        
                // Movies List - Static Container
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isLoadingMovies
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : _getFilteredMovies().isEmpty
                      ? Center(
                    child: Text(
                      _selectedStatusFilter == 'all'
                          ? 'No movies available. Tap "Add Movie" to create one.'
                          : 'No ${_selectedStatusFilter} movies found.',
                      textAlign: TextAlign.center,
                      style: ResponsiveText.textStyle(
                        context,
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  )
                      : ListView.builder(
                    // Add shrinkWrap to allow the ListView to size itself to its content
                    shrinkWrap: true,
                    // Add physics to handle scrolling properly within the container
                    physics: const ClampingScrollPhysics(),
                    itemCount: _getFilteredMovies().length,
                    itemBuilder: (context, index) {
                      final movie = _getFilteredMovies()[index];
                      return Card(
                        color: AppColors.primary.withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(
                            movie.title ?? 'Unknown Title',
                            style: ResponsiveText.textStyle(
                              context,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            '${movie.director ?? 'Unknown Director'} • ${movie.status ?? ''}',
                            style: ResponsiveText.textStyle(
                              context,
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit button
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  // Convert GetData to EditData before passing to edit screen
                                  final editData = edit_movie_model.EditData(
                                    id: movie.id,
                                    userId: movie.userId,
                                    title: movie.title,
                                    description: movie.description,
                                    genre: movie.genre,
                                    endDate: movie.endDate,
                                    director: movie.director,
                                    budget: movie.budget,
                                    status: movie.status,
                                    createdAt: movie.createdAt,
                                    updatedAt: movie.updatedAt,
                                    duration: movie.duration,
                                    cast: movie.cast,
                                    posterUrl: movie.posterUrl,
                                    genreList: movie.genreList,
                                    roles: movie.roles?.map((role) =>
                                        edit_movie_model.Roles(
                                          id: role.id,
                                          movieId: role.movieId,
                                          description: role.description,
                                          status: role.status,
                                          createdAt: role.createdAt,
                                          updatedAt: role.updatedAt,
                                          roleType: role.roleType,
                                          gender: role.gender,
                                          ageRange: role.ageRange,
                                          dialogueSample: role.dialogueSample,
                                        )).toList(),
                                  );

                                  // Navigate to edit movie screen
                                  Navigator.pushNamed(
                                    context,
                                    '/edit-movie',
                                    arguments: editData,
                                  ).then((value) {
                                    // Refresh all data after editing
                                    if (value == true) {
                                      _refreshAllData();
                                    }
                                  });
                                },
                              ),
                              // Show Auditions button
                              IconButton(
                                icon: const Icon(
                                  Icons.video_collection,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  // Navigate to roles card screen to show role cards
                                  Navigator.pushNamed(
                                    context,
                                    '/roles',
                                    arguments: {
                                      'movieId': movie.id,
                                      'movieTitle': movie.title,
                                      'roles': movie.roles,
                                    },
                                  );
                                },
                              ),
                              // Delete button
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteMovie(
                                  movie.id ?? 0,
                                  movie.title ?? 'Unknown Movie',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }
}