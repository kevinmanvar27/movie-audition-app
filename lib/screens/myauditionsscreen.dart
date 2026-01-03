import 'dart:convert';
import 'dart:io'; // Import for File class
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Import for file picker
import '../models/deleteauditionsmodel.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../models/getmyauditionsmodel.dart';
import '../util/app_colors.dart';
import '../util/responsive_text.dart';
import '../widgets/reel_player.dart';
import '../models/reel.dart';

class MyAuditionsScreen extends StatefulWidget {
  const MyAuditionsScreen({super.key});

  @override
  State<MyAuditionsScreen> createState() => _MyAuditionsScreenState();
}

class _MyAuditionsScreenState extends State<MyAuditionsScreen> {
  List<AuditionData> _auditions = [];
  bool _isLoading = true;
  String _selectedStatusFilter = 'all'; // Add status filter state
  int? _selectedMovieFilter; // Add movie filter state (null means 'all')
  // ignore: unused_field - kept for potential movie title caching
  Map<int, String> _movieTitles = {}; // Cache for movie titles

  @override
  void initState() {
    super.initState();
    _loadAuditions();
  }

  // FIXED: Implementation of _loadAuditions
  void _loadAuditions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessionManager = SessionManager();
      final token = sessionManager.authToken;
      final GetmyauditionsModel? response = await ApiService.getUserAuditions(token: token);

      if (response != null && response.success == true && response.data != null) {
        setState(() {
          _auditions = [];
          _isLoading = false;

          // The inner try-catch is for isolating data parsing errors
          try {
            print('Parsing audition data from response');

            // Get the flawed model's JSON representation
            final rawData = response.toJson();
            print('Raw response data: $rawData');

            // Access the inner 'data' array
            if (rawData['data'] != null && rawData['data']['data'] != null) {
              final List<dynamic> rawAuditionMaps = rawData['data']['data'];
              print('Number of audition maps found: ${rawAuditionMaps.length}');

              for (var item in rawAuditionMaps) {
                if (item != null) {
                  print('Raw audition item: $item');
                  // This is the line that requires the full map structure to work.
                  // If the model is not fixed, this will still produce null IDs/videos,
                  // but the code syntax is correct.
                  final audition = AuditionData.fromJson(Map<String, dynamic>.from(item));
                  print('Parsed audition ID: ${audition.id}');
                  print('Parsed uploaded videos: ${audition.uploadedVideos}');
                  _auditions.add(audition);
                }
              }
              
              // Print all auditions for debugging
              print('Total auditions loaded: ${_auditions.length}');
              for (int i = 0; i < _auditions.length; i++) {
                print('Audition $i: ID=${_auditions[i].id}, Video=${_auditions[i].uploadedVideos}');
              }
            }
          } catch (e) {
            print('Error parsing audition data: $e');
            // Do not set isLoading to false here, as we are still inside the main loading flow
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });

        // Handle unauthorized access
        if (response?.message?.contains('Unauthorized') == true || response?.message?.contains('token') == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Session expired. Please log in again.',
                      style: TextStyle(color: Colors.black)), // Black text
                  backgroundColor: Colors.white), // White background
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to load auditions',
                    style: TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load auditions',
                style: TextStyle(color: Colors.black)), // Black text
            backgroundColor: Colors.white), // White background
      );
    }
  }

  // FIXED: Implementation of _refreshAuditions
  void _refreshAuditions() {
    _loadAuditions();
  }

  // Add this method to handle audition deletion
  void _deleteAudition(int auditionId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Audition'),
          content: const Text(
              'Are you sure you want to delete this audition? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    // If user confirmed deletion
    if (confirmed == true) {
      try {
        final sessionManager = SessionManager();
        final token = sessionManager.authToken;

        // Corrected: Calling the new ApiService method
        final deleteauditionmodel? response = await ApiService.deleteAudition(
          auditionId: auditionId,
          token: token,
        );

        if (response != null && response.success == true) {
          // Refresh the auditions list
          _refreshAuditions();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Audition deleted successfully',
                      style: TextStyle(color: Colors.black)), // Black text
                  backgroundColor: Colors.white), // White background
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Failed to delete audition',
                      style: TextStyle(color: Colors.black)), // Black text
                  backgroundColor: Colors.white), // White background
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Error deleting audition',
                    style: TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
        }
      }
    }
  }

  // Add this method to handle audition editing
  void _editAudition(AuditionData audition) {
    // Show dialog to ask if user wants to change the video
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Audition'),
          content: const Text('Do you want to change the audition video?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                // Open file picker to select new video
                await _selectNewVideo(audition);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // Method to select a new video and update the audition
  Future<void> _selectNewVideo(AuditionData audition) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      // Get auth token from session
      final sessionManager = SessionManager();
      final token = sessionManager.authToken;

      if (result != null) {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Updating audition with new video...',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );

        // Update audition with new video
        final videoFile = File(result.files.single.path!);
        final response = await ApiService.updateAuditionWithVideo(
          auditionId: audition.id ?? 0,
          movieId: audition.movieId ?? 0,
          role: audition.role ?? '',
          applicantName: audition.applicantName ?? '',
          videoFile: videoFile,
          notes: audition.notes ?? '',
          token: token,
        );

        if (response != null && response.success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Audition updated successfully with new video!',
                    style: TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
          
          // Force a complete refresh of the auditions list
          await Future.delayed(const Duration(milliseconds: 1000)); // Give backend time to process
          _loadAuditions();
          
          // Also update the local audition data immediately for instant UI feedback
          if (response.data != null) {
            setState(() {
              // Find the audition in our list and update it with the new data
              for (int i = 0; i < _auditions.length; i++) {
                if (_auditions[i].id == response.data!.id) {
                  // Update the audition with the new data from the response
                  _auditions[i] = AuditionData.fromJson(response.data!.toJson());
                  break;
                }
              }
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response?.message ?? 'Failed to update audition',
                    style: const TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
        }
      } else {
        // If no file was selected, just update the text fields without changing the video
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Updating audition without changing video...',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );

        final response = await ApiService.updateAudition(
          auditionId: audition.id ?? 0,
          movieId: audition.movieId ?? 0,
          role: audition.role ?? '',
          applicantName: audition.applicantName ?? '',
          notes: audition.notes ?? '',
          token: token,
        );

        if (response != null && response.success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Audition updated successfully!',
                    style: TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
          
          // Force a complete refresh of the auditions list
          await Future.delayed(const Duration(milliseconds: 1000)); // Give backend time to process
          _loadAuditions();
          
          // Also update the local audition data immediately for instant UI feedback
          if (response.data != null) {
            setState(() {
              // Find the audition in our list and update it with the new data
              for (int i = 0; i < _auditions.length; i++) {
                if (_auditions[i].id == response.data!.id) {
                  // Update the audition with the new data from the response
                  _auditions[i] = AuditionData.fromJson(response.data!.toJson());
                  break;
                }
              }
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response?.message ?? 'Failed to update audition',
                    style: const TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to pick video',
                style: TextStyle(color: Colors.black)), // Black text
            backgroundColor: Colors.white), // White background
      );
    }
  }

  // Get unique movies from auditions
  Map<int, List<AuditionData>> _getMovieGroups() {
    Map<int, List<AuditionData>> movieGroups = {};
    
    for (var audition in _auditions) {
      final movieId = audition.movieId;
      if (movieId != null) {
        if (!movieGroups.containsKey(movieId)) {
          movieGroups[movieId] = [];
        }
        movieGroups[movieId]!.add(audition);
      }
    }
    
    return movieGroups;
  }

  // Get filtered movie groups based on selected status and movie filter
  Map<int, List<AuditionData>> _getFilteredMovieGroups() {
    final allMovieGroups = _getMovieGroups();
    
    // First filter by movie if a specific movie is selected
    Map<int, List<AuditionData>> movieFilteredGroups = {};
    if (_selectedMovieFilter != null) {
      // Only include the selected movie
      if (allMovieGroups.containsKey(_selectedMovieFilter)) {
        movieFilteredGroups[_selectedMovieFilter!] = allMovieGroups[_selectedMovieFilter]!;
      }
    } else {
      movieFilteredGroups = allMovieGroups;
    }
    
    // Then filter by status
    if (_selectedStatusFilter == 'all') {
      return movieFilteredGroups;
    }
    
    Map<int, List<AuditionData>> filteredGroups = {};
    
    movieFilteredGroups.forEach((movieId, auditions) {
      final filteredAuditions = auditions.where((audition) {
        final status = audition.status?.toLowerCase() ?? '';
        
        switch (_selectedStatusFilter) {
          case 'accepted':
            return status == 'accepted' || status == 'approved';
          case 'rejected':
            return status == 'rejected';
          case 'pending':
            return status == 'pending';
          case 'viewed':
            return status == 'viewed';
          default:
            return true;
        }
      }).toList();
      
      if (filteredAuditions.isNotEmpty) {
        filteredGroups[movieId] = filteredAuditions;
      }
    });
    
    return filteredGroups;
  }

  // Get list of unique movies for dropdown
  List<Map<String, dynamic>> _getUniqueMovies() {
    Map<int, String> uniqueMovies = {};
    for (var audition in _auditions) {
      final movieId = audition.movieId;
      final movieTitle = audition.movie?.title;
      if (movieId != null && movieTitle != null && !uniqueMovies.containsKey(movieId)) {
        uniqueMovies[movieId] = movieTitle;
      }
    }
    return uniqueMovies.entries
        .map((e) => {'id': e.key, 'title': e.value})
        .toList();
  }

  // Build movie filter dropdown
  Widget _buildMovieFilterDropdown() {
    final movies = _getUniqueMovies();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: _selectedMovieFilter,
          hint: const Text(
            'All Movies',
            style: TextStyle(color: Colors.white70),
          ),
          dropdownColor: AppColors.cardBackground,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          isExpanded: true,
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text(
                'All Movies',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ...movies.map((movie) => DropdownMenuItem<int?>(
              value: movie['id'] as int,
              child: Text(
                movie['title'] as String,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedMovieFilter = value;
            });
          },
        ),
      ),
    );
  }

  // Build filter chip
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatusFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
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
      selectedColor: AppColors.secondary,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.secondary : AppColors.border,
          width: 1,
        ),
      ),
    );
  }

  // ignore: unused_element - kept for potential video URL extraction
  String _extractFirstVideoUrl(String? uploadedVideosJson) {
    print('Processing uploadedVideosJson: $uploadedVideosJson');

    if (uploadedVideosJson == null || uploadedVideosJson.isEmpty) {
      print('No uploaded videos data found');
      return '';
    }

    // First, unescape any escaped characters
    uploadedVideosJson = uploadedVideosJson.replaceAll(r'\\/', '/');
    uploadedVideosJson = uploadedVideosJson.replaceAll(r'\/', '/');
    
    try {
      // Special case: Handle the malformed double URL format
      // e.g., https://movieaudition.rektech.work["https://movieaudition.rektech.work/storage/..."]
      RegExp doubleUrlPattern = RegExp(r'https?:\/\/[^["]*\["(https?:\/\/[^\]]*)"\]');
      Match? doubleUrlMatch = doubleUrlPattern.firstMatch(uploadedVideosJson);
      if (doubleUrlMatch != null && doubleUrlMatch.groupCount >= 1) {
        String extractedUrl = doubleUrlMatch.group(1)!;
        print('Extracted URL from double URL format: $extractedUrl');
        // Normalize multiple slashes
        extractedUrl = extractedUrl.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
        // Ensure it starts with https
        if (extractedUrl.startsWith('http://')) {
          extractedUrl = extractedUrl.replaceFirst('http://', 'https://');
        }
        return extractedUrl;
      }
      
      // 1. Case 1: It's already a direct URL
      if (uploadedVideosJson.startsWith('http')) {
        print('Direct URL found: $uploadedVideosJson');
        // Normalize multiple slashes
        String normalizedUrl = uploadedVideosJson.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
        // Ensure it starts with https
        if (normalizedUrl.startsWith('http://')) {
          normalizedUrl = normalizedUrl.replaceFirst('http://', 'https://');
        }
        return normalizedUrl;
      }

      // 2. Case 2: It's a JSON array string (The format observed in your log)
      if (uploadedVideosJson.trim().startsWith('[') && uploadedVideosJson.trim().endsWith(']')) {
        // Decode the JSON string into a List of video URLs (which are strings)
        final List<dynamic> videoUrls = jsonDecode(uploadedVideosJson);
        print('Parsed video URLs array: $videoUrls');

        if (videoUrls.isNotEmpty) {
          String firstUrl = videoUrls[0].toString().replaceAll(r'\\/', '/');
          firstUrl = firstUrl.replaceAll(r'\/', '/');
          print('First item from array: $firstUrl');

          // Ensure it's a valid URL
          if (firstUrl.startsWith('http')) {
            print('Valid URL extracted from array: $firstUrl');
            // Normalize multiple slashes
            String normalizedUrl = firstUrl.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
            // Ensure it starts with https
            if (normalizedUrl.startsWith('http://')) {
              normalizedUrl = normalizedUrl.replaceFirst('http://', 'https://');
            }
            return normalizedUrl;
          } else {
            // Handle relative URLs by adding the base URL
            String normalizedUrl = 'https://movieaudition.rektech.work$firstUrl';
            // Normalize multiple slashes
            normalizedUrl = normalizedUrl.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
            print('Normalized URL: $normalizedUrl');
            return normalizedUrl;
          }
        }
      }

      // 3. Case 3: It's a JSON object string containing a URL
      if (uploadedVideosJson.trim().startsWith('{') && uploadedVideosJson.trim().endsWith('}')) {
        final Map<String, dynamic> videoData = jsonDecode(uploadedVideosJson);
        print('Parsed video data object: $videoData');
        // Try common keys for video URLs
        final possibleKeys = ['url', 'path', 'video_url', 'video'];
        for (final key in possibleKeys) {
          if (videoData.containsKey(key) && videoData[key] != null) {
            String url = videoData[key].toString().replaceAll(r'\\/', '/');
            url = url.replaceAll(r'\/', '/');
            if (url.startsWith('http')) {
              print('URL found in object with key $key: $url');
              // Normalize multiple slashes
              String normalizedUrl = url.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
              // Ensure it starts with https
              if (normalizedUrl.startsWith('http://')) {
                normalizedUrl = normalizedUrl.replaceFirst('http://', 'https://');
              }
              return normalizedUrl;
            } else if (url.isNotEmpty) {
              // Handle relative URLs by adding the base URL
              String normalizedUrl = 'https://movieaudition.rektech.work$url';
              // Normalize multiple slashes
              normalizedUrl = normalizedUrl.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
              print('Normalized URL from object: $normalizedUrl');
              return normalizedUrl;
            }
          }
        }
      }

      // 4. Case 4: It's a plain string that might be a relative path
      if (uploadedVideosJson.isNotEmpty && !uploadedVideosJson.startsWith('http')) {
        String normalizedUrl = 'https://movieaudition.rektech.work$uploadedVideosJson';
        // Normalize multiple slashes
        normalizedUrl = normalizedUrl.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
        print('Normalized plain path: $normalizedUrl');
        return normalizedUrl;
      }

    } catch (e) {
      print('Error parsing video URLs: $e');
    }

    // Fallback: Check if the original string starts with 'http' (handles edge cases where jsonDecode fails)
    if (uploadedVideosJson.startsWith('http')) {
      print('Fallback URL after error: $uploadedVideosJson');
      // Normalize multiple slashes
      String normalizedUrl = uploadedVideosJson.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
      // Ensure it starts with https
      if (normalizedUrl.startsWith('http://')) {
        normalizedUrl = normalizedUrl.replaceFirst('http://', 'https://');
      }
      return normalizedUrl;
    }

    print('No valid video URL found');
    return '';
  }

  // ignore: unused_element - kept for compatibility
  void _updateStatus(int index, ReelStatus status) {
    // This method is kept for compatibility but won't be used with AuditionData
    setState(() {});
  }

  // ignore: unused_element - kept for potential profile navigation
  void _openProfile(Reel reel) {
    // Navigate to the main profile screen
    Navigator.pushNamed(context, '/profile');
  }

  // FIXED: Implementation of the required 'build' method
  @override
  Widget build(BuildContext context) {
    final filteredMovieGroups = _getFilteredMovieGroups();
    final movieEntries = filteredMovieGroups.entries.toList();
    
    return Scaffold(
      appBar: const CustomHeader(
        title: 'My Auditions',
      ),
      endDrawer: const CustomDrawer(),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Auditions by Movie:',
                    style: ResponsiveText.textStyle(
                      context,
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Movie Filter Dropdown
                  _buildMovieFilterDropdown(),
                  const SizedBox(height: 12),
                  // Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Accepted', 'accepted'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Rejected', 'rejected'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Pending', 'pending'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Viewed', 'viewed'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: movieEntries.isEmpty
                        ? Center(
                            child: Text(
                              _selectedStatusFilter == 'all'
                                  ? 'No auditions found'
                                  : 'No ${_selectedStatusFilter} auditions found',
                              style: ResponsiveText.textStyle(
                                context,
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: ResponsiveText.isTablet(context) ? 0.65 : 0.7,
                            ),
                            itemCount: movieEntries.length,
                            itemBuilder: (context, index) {
                              // ignore: unused_local_variable - kept for potential future use
                              final movieId = movieEntries[index].key;
                              final auditions = movieEntries[index].value;
                              final firstAudition = auditions.first;
                              final movieTitle = firstAudition.movie?.title ?? 'Unknown Movie';
                              
                              return GestureDetector(
                                onTap: () {
                                  // Navigate to reels page with movie auditions
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => _MyAuditionsReelView(
                                        auditions: auditions,
                                        movieTitle: movieTitle,
                                        onDelete: (auditionId) => _deleteAudition(auditionId),
                                        onEdit: (audition) => _editAudition(audition),
                                      ),
                                    ),
                                  ).then((_) => _refreshAuditions());
                                },
                                child: Card(
                                  color: AppColors.cardBackground,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Movie Poster
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(12.0),
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.movie,
                                              size: 50,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                                Text(
                                                  movieTitle,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(width:5),
                                                Text(
                                                  firstAudition.role!,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '${auditions.length} audition${auditions.length > 1 ? "s" : ""}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.secondary,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'View Videos',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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

// Separate widget for reel view
class _MyAuditionsReelView extends StatefulWidget {
  final List<AuditionData> auditions;
  final String movieTitle;
  final Function(int) onDelete;
  final Function(AuditionData) onEdit;

  const _MyAuditionsReelView({
    required this.auditions,
    required this.movieTitle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_MyAuditionsReelView> createState() => _MyAuditionsReelViewState();
}

class _MyAuditionsReelViewState extends State<_MyAuditionsReelView> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ignore: unused_element - kept for potential video URL extraction
  String _extractFirstVideoUrl(String? uploadedVideosJson) {
    print('Processing uploadedVideosJson: $uploadedVideosJson');

    if (uploadedVideosJson == null || uploadedVideosJson.isEmpty) {
      print('No uploaded videos data found');
      return '';
    }

    // First, unescape any escaped characters
    uploadedVideosJson = uploadedVideosJson.replaceAll(r'\\/', '/');
    uploadedVideosJson = uploadedVideosJson.replaceAll(r'\/', '/');
    
    try {
      // Special case: Handle the malformed double URL format
      RegExp doubleUrlPattern = RegExp(r'https?:\/\/[^["]*\["(https?:\/\/[^\]]*)"\]');
      Match? doubleUrlMatch = doubleUrlPattern.firstMatch(uploadedVideosJson);
      if (doubleUrlMatch != null && doubleUrlMatch.groupCount >= 1) {
        String extractedUrl = doubleUrlMatch.group(1)!;
        print('Extracted URL from double URL format: $extractedUrl');
        extractedUrl = extractedUrl.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
        if (extractedUrl.startsWith('http://')) {
          extractedUrl = extractedUrl.replaceFirst('http://', 'https://');
        }
        return extractedUrl;
      }
      
      // Case 1: It's already a direct URL
      if (uploadedVideosJson.startsWith('http')) {
        print('Direct URL found: $uploadedVideosJson');
        String normalizedUrl = uploadedVideosJson.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
        if (normalizedUrl.startsWith('http://')) {
          normalizedUrl = normalizedUrl.replaceFirst('http://', 'https://');
        }
        return normalizedUrl;
      }

      // Case 2: It's a JSON array string
      if (uploadedVideosJson.trim().startsWith('[') && uploadedVideosJson.trim().endsWith(']')) {
        final List<dynamic> videoUrls = jsonDecode(uploadedVideosJson);
        print('Parsed video URLs array: $videoUrls');

        if (videoUrls.isNotEmpty) {
          String firstUrl = videoUrls[0].toString().replaceAll(r'\\/', '/');
          firstUrl = firstUrl.replaceAll(r'\/', '/');
          print('First item from array: $firstUrl');

          if (firstUrl.startsWith('http')) {
            print('Valid URL extracted from array: $firstUrl');
            String normalizedUrl = firstUrl.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
            if (normalizedUrl.startsWith('http://')) {
              normalizedUrl = normalizedUrl.replaceFirst('http://', 'https://');
            }
            return normalizedUrl;
          } else {
            String normalizedUrl = 'https://movieaudition.rektech.work$firstUrl';
            normalizedUrl = normalizedUrl.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
            print('Normalized URL: $normalizedUrl');
            return normalizedUrl;
          }
        }
      }

      // Case 3: It's a JSON object string
      if (uploadedVideosJson.trim().startsWith('{') && uploadedVideosJson.trim().endsWith('}')) {
        final Map<String, dynamic> videoData = jsonDecode(uploadedVideosJson);
        print('Parsed video data object: $videoData');
        final possibleKeys = ['url', 'path', 'video_url', 'video'];
        for (final key in possibleKeys) {
          if (videoData.containsKey(key) && videoData[key] != null) {
            String url = videoData[key].toString().replaceAll(r'\\/', '/');
            url = url.replaceAll(r'\/', '/');
            if (url.startsWith('http')) {
              print('URL found in object with key $key: $url');
              String normalizedUrl = url.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
              if (normalizedUrl.startsWith('http://')) {
                normalizedUrl = normalizedUrl.replaceFirst('http://', 'https://');
              }
              return normalizedUrl;
            } else if (url.isNotEmpty) {
              String normalizedUrl = 'https://movieaudition.rektech.work$url';
              normalizedUrl = normalizedUrl.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
              print('Normalized URL from object: $normalizedUrl');
              return normalizedUrl;
            }
          }
        }
      }

      // Case 4: Plain string relative path
      if (uploadedVideosJson.isNotEmpty && !uploadedVideosJson.startsWith('http')) {
        String normalizedUrl = 'https://movieaudition.rektech.work$uploadedVideosJson';
        normalizedUrl = normalizedUrl.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
        print('Normalized plain path: $normalizedUrl');
        return normalizedUrl;
      }

    } catch (e) {
      print('Error parsing video URLs: $e');
    }

    if (uploadedVideosJson.startsWith('http')) {
      print('Fallback URL after error: $uploadedVideosJson');
      String normalizedUrl = uploadedVideosJson.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
      if (normalizedUrl.startsWith('http://')) {
        normalizedUrl = normalizedUrl.replaceFirst('http://', 'https://');
      }
      return normalizedUrl;
    }

    print('No valid video URL found');
    return '';
  }

  void _updateStatus(int index, ReelStatus status) {
    setState(() {});
  }

  void _openProfile(Reel reel) {
    Navigator.pushNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: widget.movieTitle,
        actions: widget.auditions.isNotEmpty && _currentPageIndex < widget.auditions.length
            ? [
          // Check if the current audition status allows editing/deleting
          if (_shouldShowEditDeleteButtons(widget.auditions[_currentPageIndex])) ...[
            IconButton(
              icon: const Icon(
                Icons.edit,
                color: AppColors.textPrimary,
              ),
              onPressed: () => widget.onEdit(widget.auditions[_currentPageIndex]),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: AppColors.textPrimary,
              ),
              onPressed: () => widget.onDelete(widget.auditions[_currentPageIndex].id ?? 0),
            ),
          ]
        ]
            : null,
      ),
      endDrawer: const CustomDrawer(),
      backgroundColor: AppColors.background,
      body: widget.auditions.isEmpty
          ? const Center(
        child: Text(
          'No auditions found',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
      )
          : PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.auditions.length,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final audition = widget.auditions[index];
          print('Building widget for audition ID: ${audition.id}');

          final videoUrl = _extractFirstVideoUrl(audition.uploadedVideos);
          print('Extracted video URL: $videoUrl');
          print('Original uploadedVideos: ${audition.uploadedVideos}');

          if (videoUrl.isEmpty) {
            print('No video URL found for audition ID: ${audition.id}');
            return const Center(
              child: Text(
                'No video available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            );
          }

          final convertedReel = Reel(
            assetPath: videoUrl,
            caption: audition.role ?? "Unknown Role",
            movieTitle: audition.movie?.title ?? "Unknown Movie",
            currentStatus: audition.status ?? "pending",
            auditionId: audition.id,
          );
          print('Created Reel with assetPath: ${convertedReel.assetPath}');

          final shouldPlay = (index - _currentPageIndex).abs() <= 1;
          print('Should play video for audition ID ${audition.id}: $shouldPlay');

          return Container(
            color: Colors.black,
            child: ReelPlayer(
              key: ValueKey(audition.id),
              reel: convertedReel,
              shouldPlay: shouldPlay,
              onStatusChanged: (s) => _updateStatus(index, s),
              onOpenProfile: () => _openProfile(convertedReel),
            ),
          );
        },
      ),
    );
  }

  // Helper method to determine if edit and delete buttons should be shown
  bool _shouldShowEditDeleteButtons(AuditionData audition) {
    final status = audition.status?.toLowerCase();
    // Show buttons only for pending or viewed status
    return status == 'pending' || status == 'viewed';
  }

}
