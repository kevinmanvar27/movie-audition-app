import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:ui'; // Add this import for ImageFilter
import '../models/reel.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../util/app_colors.dart';
import '../models/role.dart';

class ReelPlayer extends StatefulWidget {
  final Reel reel;
  final bool shouldPlay;
  final ValueChanged<ReelStatus> onStatusChanged;
  final VoidCallback onOpenProfile;

  const ReelPlayer({
    super.key,
    required this.reel,
    required this.shouldPlay,
    required this.onStatusChanged,
    required this.onOpenProfile,
  });

  @override
  State<ReelPlayer> createState() => _ReelPlayerState();
}

class _ReelPlayerState extends State<ReelPlayer> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _muted = false;
  bool _isDisposed = false;
  bool _isUpdatingStatus = false;
  bool _hasBeenViewed = false; // Track if the audition has been viewed

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  void _initVideoPlayer() {
    if (_isDisposed) return;

    try {
      print('Initializing video player with asset path: ${widget.reel.assetPath}');

      // Dispose of any existing controller
      _controller?.dispose();

      // Initialize video controller with network URL or asset
      if (widget.reel.assetPath.startsWith('http')) {
        _controller = VideoPlayerController.network(widget.reel.assetPath);
      } else {
        _controller = VideoPlayerController.asset(widget.reel.assetPath);
      }

      _controller!.initialize().then((_) {
        if (!mounted || _isDisposed) return;
        setState(() {
          _isReady = true;
        });
        _controller!.setLooping(true);
        _controller!.setVolume(_muted ? 0 : 1);
        if (widget.shouldPlay) {
          _controller!.play();
        }
      }).catchError((error) {
        print('Error initializing video player: $error');
        if (mounted && !_isDisposed) {
          setState(() {
            _isReady = false;
          });
        }
      });
    } catch (e) {
      print('Exception in _initVideoPlayer: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isReady = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant ReelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.reel.assetPath != widget.reel.assetPath) {
      // Reinitialize the video player with the new asset path
      _initVideoPlayer();
    } else {
      // Handle play/pause based on shouldPlay flag
      if (_isReady && mounted && !_isDisposed) {
        if (widget.shouldPlay && !_controller!.value.isPlaying) {
          _controller!.play();
        } else if (!widget.shouldPlay && _controller!.value.isPlaying) {
          _controller!.pause();
        }
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void _toggleMute() {
    if (!mounted || _isDisposed || _controller == null) return;
    setState(() => _muted = !_muted);
    _controller!.setVolume(_muted ? 0 : 1);
  }

  void _togglePlay() {
    if (!_isReady || !mounted || _isDisposed || _controller == null) return;
    _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
  }

  // Method to update audition status
  Future<void> _updateAuditionStatus(String status) async {
    if (widget.reel.auditionId == null) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    final sessionManager = SessionManager();
    final token = sessionManager.authToken;

    final success = await ApiService.updateAuditionStatus(
      auditionId: widget.reel.auditionId!, // Correct parameter name
      status: status,
      token: token,
    );

    if (mounted && !_isDisposed) {
      setState(() {
        _isUpdatingStatus = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audition ${status == 'shortlisted' ? 'shortlisted' : 'rejected'} successfully',
                style: const TextStyle(color: Colors.black)), // Black text
            backgroundColor: Colors.white, // White background
          ),
        );
        
        // Update local status
        if (status == 'shortlisted') {
          widget.onStatusChanged(ReelStatus.accepted); // Using accepted enum for shortlisted status
        } else if (status == 'rejected') {
          widget.onStatusChanged(ReelStatus.rejected);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update audition status', 
                style: TextStyle(color: Colors.black)), // Black text
            backgroundColor: Colors.white, // White background
          ),
        );
      }
    }
  }

  // Method to mark audition as viewed when casting director first sees it
  Future<void> _markAsViewed() async {
    // Only proceed if this is a casting director viewing a pending audition
    if (_hasBeenViewed || widget.reel.auditionId == null) return;
    
    // Get user role ID
    final sessionManager = SessionManager();
    final userRoleId = sessionManager.userRoleId;
    
    // Only for casting directors (role ID 2)
    if (userRoleId != 2) return;
    
    // Only update if current status is pending
    if (widget.reel.currentStatus != 'pending') return;
    
    setState(() {
      _hasBeenViewed = true;
    });

    final token = sessionManager.authToken;

    final success = await ApiService.updateAuditionStatus(
      auditionId: widget.reel.auditionId!,
      status: 'viewed',
      token: token,
    );

    if (mounted && !_isDisposed && success) {
      // Update local status
      widget.onStatusChanged(ReelStatus.viewed);
    }
  }

  // Helper method to get user role ID
  Future<int?> _getUserRoleId() async {
    final sessionManager = SessionManager();
    return sessionManager.userRoleId;
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'shortlisted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'viewed':
        return AppColors.primary;
      case 'pending':
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building ReelPlayer');
    print('Reel assetPath: ${widget.reel.assetPath}');
    print('Reel actorData: ${widget.reel.actorData != null}');
    if (widget.reel.actorData != null) {
      print('Actor name: ${widget.reel.actorData!.name}');
      print('Actor gallery: ${widget.reel.actorData!.imageGallery}');
      print('Actor gallery length: ${widget.reel.actorData!.imageGallery?.length}');
    }
    print('Reel notes: ${widget.reel.notes}');
    print('Reel auditionId: ${widget.reel.auditionId}');
    print('Reel currentStatus: ${widget.reel.currentStatus}');
    
    final topPad = MediaQuery.of(context).padding.top;
    return VisibilityDetector(
      key: ValueKey(widget.reel.assetPath),
      onVisibilityChanged: (info) {
        if (!_isReady || !mounted || _isDisposed || _controller == null) return;
        
        // Mark as viewed when 50% visible for casting directors
        if (info.visibleFraction > 0.5 && !_hasBeenViewed) {
          _markAsViewed();
        }

        // Auto-play/pause based on visibility
        if (info.visibleFraction > 0.5) {
          if (widget.shouldPlay && !_controller!.value.isPlaying) {
            _controller!.play();
          }
        } else {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
          }
        }
      },
      child: Stack(
        children: [
          // Video Player
          if (_isReady && _controller != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: _togglePlay,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            // Loading or error placeholder
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // Play/Pause overlay when not playing
          if (_isReady && _controller != null && !_controller!.value.isPlaying)
            Positioned.fill(
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),

          // Top Right Controls
          Positioned(
            top: topPad + 16,
            right: 16,
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggleMute,
                  iconSize: 28,
                  color: Colors.white,
                  icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                ),
              ],
            ),
          ),

          // Audition Information Card - Show for both casting directors and actors
          // Positioned at the bottom of the screen with glass morphism effect
          Positioned(
            left: 16,
            right: 16,
            bottom: 50,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // Glass morphism effect
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column with movie title, actor name, role name, notes and status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Movie title
                              if (widget.reel.movieTitle != null && widget.reel.movieTitle!.isNotEmpty) ...[
                                Text(
                                  widget.reel.movieTitle!,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                              ],
                              // Actor name with tap gesture to navigate to profile (only for casting directors)
                              if (widget.reel.actorData?.name != null && widget.reel.actorData!.name!.isNotEmpty) ...[
                                FutureBuilder<int?>(
                                  future: _getUserRoleId(), // Get user role ID
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.data == 2) { // 2 is casting director
                                      return GestureDetector(
                                        onTap: widget.onOpenProfile, // Navigate to actor profile on tap
                                        child: Text(
                                          widget.reel.actorData!.name!,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            decoration: TextDecoration.underline,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    } else {
                                      // For actors, just show the name without tap gesture
                                      return Text(
                                        widget.reel.actorData!.name!,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 4),
                              ],
                              // Role name/caption
                              if (widget.reel.caption != null && widget.reel.caption!.isNotEmpty) ...[
                                Text(
                                  widget.reel.caption!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                              ],
                              // Notes (only for casting directors)
                              FutureBuilder<int?>(
                                future: _getUserRoleId(), // Get user role ID
                                builder: (context, snapshot) {
                                  if (snapshot.hasData && snapshot.data == 2 && // 2 is casting director
                                      widget.reel.notes != null && widget.reel.notes!.isNotEmpty) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Notes: ${widget.reel.notes}',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                              // Current status display
                              if (widget.reel.currentStatus != null && widget.reel.currentStatus!.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(widget.reel.currentStatus!).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getStatusColor(widget.reel.currentStatus!),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.reel.currentStatus!.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(widget.reel.currentStatus!),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Right column with status buttons (only for casting directors)
                        FutureBuilder<int?>(
                          future: _getUserRoleId(), // Get user role ID
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data == 2) { // 2 is casting director
                              return _isUpdatingStatus
                                  ? CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.secondary,
                                      ),
                                    )
                                  : Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _updateAuditionStatus('shortlisted');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          elevation: 4,
                                        ),
                                        child: const Text(
                                          'Accept',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width:10),
                                      ElevatedButton(
                                        onPressed: () {
                                          _updateAuditionStatus('rejected');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          elevation: 4,
                                        ),
                                        child: const Text(
                                          'Reject',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}