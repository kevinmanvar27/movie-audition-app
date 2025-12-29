import 'package:flutter/material.dart';
import 'dart:convert';
import '../../widgets/reel_player.dart';
import '../../models/reel.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/custom_header.dart';
import '../../services/api_service.dart';
import '../../services/session_manager.dart';
import '../../models/apireel.dart';
import '../../models/getsubmittedmodel.dart'; // Add this import
import '../../screens/actorprofile.dart'; // Add ActorProfileScreen import

class ReelsPage extends StatefulWidget {
  final int? movieId; // Add movieId parameter
  final int? initialIndex; // Add initial index parameter
  final String? roleFilter; // Add role filter parameter

  const ReelsPage({super.key, this.movieId, this.initialIndex, this.roleFilter}); // Update constructor

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  final PageController _pageController = PageController();
  int _current = 0;
  List<ApiReel> _reels = [];
  List<Data>? _auditions; // Add auditions list
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.movieId != null) {
      _loadMovieAuditions(widget.movieId!); // Load auditions if movieId is provided
    } else {
      _loadReels(); // Load regular reels if no movieId
    }

    // Set initial page if provided
    if (widget.initialIndex != null && widget.initialIndex! > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(widget.initialIndex!);
        }
      });
    }
  }

  void _loadMovieAuditions(int movieId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessionManager = SessionManager();
      final token = sessionManager.authToken;
      final userRoleId = sessionManager.userRoleId;
      final userId = sessionManager.userId;
      
      final response = await ApiService.getMovieAuditions(movieId: movieId, token: token);

      if (response != null && response.success == true) {
        // Filter auditions based on user role
        List<Data>? filteredAuditions;
        
        if (userRoleId == 3 && userId != null) { // Actor role
          // For actors, only show their own auditions
          filteredAuditions = response.data?.where((audition) => audition.userId == userId).toList();
        } else {
          // For casting directors and others, show all auditions
          filteredAuditions = response.data;
        }
        
        setState(() {
          _auditions = filteredAuditions;
        });

        // Convert auditions to reels for display
        _convertAuditionsToReels();

        setState(() {
          _isLoading = false;
        });
      } else {
        // Handle error
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

  void _convertAuditionsToReels() {
    if (_auditions == null) return;

    print('Converting ${_auditions!.length} auditions to reels');

    // Filter auditions by role if roleFilter is provided
    List<Data> filteredAuditions = _auditions!;
    if (widget.roleFilter != null && widget.roleFilter!.isNotEmpty) {
      filteredAuditions = _auditions!.where((audition) => audition.role == widget.roleFilter).toList();
      print('Filtered to ${filteredAuditions.length} auditions for role: ${widget.roleFilter}');
    }

    setState(() {
      _reels = filteredAuditions.map((audition) {
        // Process the video URL to ensure it's a full URL
        String videoUrl = audition.uploadedVideos ?? '';
        print('Original video URL: $videoUrl');
        if (videoUrl.isNotEmpty) {
          // Handle when videoUrl is a string representation of an array
          if (videoUrl.startsWith('[') && videoUrl.endsWith(']')) {
            try {
              // Parse the JSON array
              List<dynamic> urls = json.decode(videoUrl);
              if (urls.isNotEmpty) {
                videoUrl = urls[0].toString();
              }
            } catch (e) {
              // If JSON parsing fails, keep the original string
              print('Failed to parse video URL as JSON array: $e');
            }
          }
          // Special case: Handle the malformed double URL format
          // e.g., https://movieaudition.rektech.work["https://movieaudition.rektech.work/storage/..."]
          else if (videoUrl.contains('[') && videoUrl.contains('"http')) {
            RegExp doubleUrlPattern = RegExp(r'https?:\/\/[^["]*\["(https?:\/\/[^\]]*)"\]');
            Match? doubleUrlMatch = doubleUrlPattern.firstMatch(videoUrl);
            if (doubleUrlMatch != null && doubleUrlMatch.groupCount >= 1) {
              videoUrl = doubleUrlMatch.group(1)!;
              print('Extracted URL from double URL format: $videoUrl');
            }
          }

          // First unescape any escaped characters (especially escaped forward slashes)
          videoUrl = videoUrl.replaceAll(r'\\/', '/');
          videoUrl = videoUrl.replaceAll(r'\/', '/');

          // Handle special case where URL might have escaped quotes
          videoUrl = videoUrl.replaceAll(r'\"', '"');

          // Normalize multiple slashes
          videoUrl = videoUrl.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');

          // If it's a relative path, prepend the base URL
          if (!videoUrl.startsWith('http')) {
            videoUrl = 'https://movieaudition.rektech.work$videoUrl';
          }

          // Ensure the URL starts with https
          if (videoUrl.startsWith('http://')) {
            videoUrl = videoUrl.replaceFirst('http://', 'https://');
          }

          // Additional check for URLs that start with https but have escaped characters
          if (videoUrl.startsWith('https:\/\/') || videoUrl.startsWith('http:\/\/')) {
            videoUrl = videoUrl.replaceAll(r'\/', '/');
          }

          print('Converted to full URL: $videoUrl');
        }

        // Extract movie title from audition data
        String? movieTitle;
        if (audition.movie != null) {
          movieTitle = audition.movie!.title;
        }

        final reel = ApiReel(
          id: audition.id ?? 0,
          videoUrl: videoUrl,
          caption: audition.role ?? 'Audition Video',
          fullName: audition.user?.name ?? 'Unknown User',
          username: audition.user?.email ?? '',
          avatarUrl: audition.user?.profilePhoto ?? '',
          createdAt: audition.createdAt ?? '',
          likes: 0,
          comments: 0,
          isLiked: false,
        );

        print('Created ApiReel with videoUrl: ${reel.videoUrl}');

        return reel;
      }).toList();

      print('Converted to ${_reels.length} reels');
    });
  }

  void _loadReels() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessionManager = SessionManager();
      final token = sessionManager.authToken;
      final response = await ApiService.getReels(token: token);

      if (response != null && response.success) {
        setState(() {
          _reels = response.data;
          _isLoading = false;
        });
      } else {
        // Handle unauthorized access
        if (response?.message?.contains('Unauthorized') == true || response?.message?.contains('token') == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Session expired. Please log in again.',
                      style: TextStyle(color: Colors.black)), // Black text
                  backgroundColor: Colors.white), // White background
            );
            // Optionally redirect to login screen
            // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        }
        // Fallback to hardcoded data if API fails
      }
    } catch (e) {
    }
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateStatus(int index, ReelStatus status) {
    // Update the status in the auditions list
    if (_auditions != null && index < _auditions!.length) {
      setState(() {
        // Update the audition status
        String statusString = Reel.statusToString(status);
        _auditions![index] = Data.fromJson({
          ..._auditions![index].toJson(),
          'status': statusString,
        });
        
        // Also update the corresponding reel's currentStatus
        if (index < _reels.length) {
          // We'll need to refresh the reels by converting auditions again
          _convertAuditionsToReels();
        }
      });
    }
  }

  void _openProfile(Reel reel) {
    // Navigate to the ActorProfileScreen with the actor data and movieId
    if (reel.actorData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActorProfileScreen(
            actor: reel.actorData!,
            movieId: widget.movieId, // Pass the movieId to the ActorProfileScreen
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building ReelsPage with ${_reels.length} reels');
    return Scaffold(
      appBar: CustomHeader(
        title: widget.movieId != null ? 'Movie Auditions' : 'Reels', // Update title based on context
      ),
      endDrawer: CustomDrawer(), // Changed from drawer to endDrawer
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reels.isEmpty
              ? const Center(
                  child: Text(
                    'No reels found',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _reels.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (context, index) {
                    final reel = _reels[index];
                    print('Building reel at index $index with videoUrl: ${reel.videoUrl}');

                    // Convert ApiReel to Reel for compatibility with existing ReelPlayer
                    // Check if we have audition data (for casting directors viewing auditions)
                    final auditionData = widget.movieId != null && _auditions != null && index < _auditions!.length
                        ? _auditions![index]
                        : null;

                    // Extract movie title from audition data
                    String? movieTitle;
                    if (auditionData?.movie != null) {
                      movieTitle = auditionData!.movie!.title;
                    } else if (auditionData?.movie != null) {
                      movieTitle = auditionData!.movie!.title;
                    }

                    final convertedReel = Reel(
                      assetPath: reel.videoUrl,
                      caption: reel.caption,
                      actorData: auditionData?.user,
                      notes: auditionData?.notes,
                      auditionId: auditionData?.id,
                      currentStatus: auditionData?.status,
                      movieTitle: auditionData?.movie?.title, // Pass movie title to Reel object
                    );
                    
                    // Debug print to check actor data
                    if (auditionData?.user != null) {
                      print('Actor data: ${auditionData!.user!.toJson()}');
                      print('Actor gallery: ${auditionData!.user!.imageGallery}');
                      print('Actor gallery length: ${auditionData!.user!.imageGallery?.length}');
                    }

                    print('Converted to Reel with assetPath: ${convertedReel.assetPath}');

                    // Only autoplay videos that are close to the current page to reduce resource usage
                    final shouldPlay = (index - _current).abs() <= 1;

                    return ReelPlayer(
                      reel: convertedReel,
                      shouldPlay: shouldPlay,
                      onStatusChanged: (s) => _updateStatus(index, s),
                      onOpenProfile: () => _openProfile(convertedReel),
                    );
                  },
                ),
    );
  }
}