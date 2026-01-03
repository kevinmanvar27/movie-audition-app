import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Added import
// ignore: unused_import - kept for potential date formatting
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'dart:io'; // Import for File class
import '../util/customTextformfield.dart';
import '../util/custombutton.dart';
import '../util/customdropdown.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import '../models/getmoviemodel.dart'; // Import the movie model
// ignore: unused_import - kept for potential audition model usage
import '../models/addauditionsmodel.dart'; // Import the add audition model
import '../util/app_colors.dart';
import '../util/responsive_text.dart';
import '../util/date_formatter.dart'; // Add this import
import '../services/session_manager.dart'; // Import session manager for user data
import '../services/api_service.dart'; // Import API service for audition submission

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  String? _selectedRole;
  GetData? _movieData; // Changed to use the GetData model from getmoviemodel
  String? _videoPath; // Added to store selected video path
  String? _videoName; // Added to store selected video name
  int? _userRoleId; // Add user role ID
  bool _isSubmitting = false; // Add submission state

  @override
  void initState() {
    super.initState();
    // Initialize _selectedRole to null to avoid dropdown assertion error
    _selectedRole = null;
    
    // Get user role ID
    final sessionManager = SessionManager();
    _userRoleId = sessionManager.userRoleId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get movie data passed from previous screen
    _movieData = ModalRoute.of(context)?.settings.arguments as GetData?;
    
    // Auto-fill user's name from session or load from API
    _loadUserName();
  }
  
  // Load user's name from profile
  Future<void> _loadUserName() async {
    final sessionManager = SessionManager();
    
    // First try to get from session
    if (sessionManager.userName != null && sessionManager.userName!.isNotEmpty) {
      setState(() {
        _nameController.text = sessionManager.userName!;
      });
    }
    
    // Also load from API to get most up-to-date name
    try {
      final token = sessionManager.authToken;
      if (token != null) {
        final profileResponse = await ApiService.getProfileData(token: token);
        if (profileResponse != null && profileResponse.success == true) {
          final profileName = profileResponse.data?.name;
          if (profileName != null && profileName.isNotEmpty) {
            setState(() {
              _nameController.text = profileName;
            });
          }
        }
      }
    } catch (e) {
      // If API fails, keep the session name
      print('Failed to load profile name: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Added method to handle video selection
  Future<void> _selectVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _videoPath = result.files.single.path;
          _videoName = result.files.single.name;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Selected: $_videoName',
                  style: const TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
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

  // Check if user has already applied for this role in this movie
  Future<bool> _hasAlreadyAppliedForRole(String role) async {
    try {
      final sessionManager = SessionManager();
      final token = sessionManager.authToken;
      
      // Get user's existing auditions
      final userAuditions = await ApiService.getUserAuditions(token: token);
      
      if (userAuditions != null && 
          userAuditions.success == true && 
          userAuditions.data?.data != null) {
        
        // Check if any audition matches the current movie ID and role
        for (var audition in userAuditions.data!.data!) {
          if (audition.movieId == _movieData?.id && audition.role == role) {
            return true; // Found existing audition for this role
          }
        }
      }
      
      return false; // No existing audition found for this role
    } catch (e) {
      print('Error checking existing auditions: $e');
      return false; // Assume no existing audition on error
    }
  }

  void _submitAudition() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a role',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
        return;
      }
      
      // Check if video is selected
      if (_videoPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a video',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
        return;
      }
      
      // Check if user has already applied for this role
      setState(() {
        _isSubmitting = true;
      });
      
      final hasApplied = await _hasAlreadyAppliedForRole(_selectedRole!);
      
      if (hasApplied) {
        setState(() {
          _isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already applied for this role. You cannot apply multiple times for the same role.',
                style: TextStyle(color: Colors.black)), // Black text
            backgroundColor: Colors.white, // White background
          ),
        );
        return;
      }
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Submitting audition...',
                style: TextStyle(color: Colors.black)), // Black text
            backgroundColor: Colors.white), // White background
      );
      
      // Get auth token from session
      final sessionManager = SessionManager();
      final token = sessionManager.authToken;
      
      // Submit audition with video file via API
      final videoFile = File(_videoPath!);
      final response = await ApiService.submitAuditionWithVideo(
        movieId: _movieData?.id ?? 0,
        role: _selectedRole!,
        applicantName: _nameController.text,
        videoFile: videoFile,
        notes: _notesController.text,
        token: token,
      );
      
      setState(() {
        _isSubmitting = false;
      });
      
      if (response != null && response.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Audition submitted successfully!',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
        
        // Navigate back to movies screen
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response?.message ?? 'Failed to submit audition',
                  style: const TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
      }
    }
  }
  
  // Get filtered roles based on user role
  List<String> _getFilteredRoles() {
    // If user is an actor (role ID = 3), only show roles created by casting directors
    if (_userRoleId == 3 && _movieData?.roles != null) {
      // Filter roles to show only those with valid roleType
      return _movieData!.roles!
          .where((role) => role.roleType != null && role.roleType!.isNotEmpty)
          .map((role) => role.roleType!)
          .toSet() // Remove duplicates
          .toList();
    }
    
    // For other users or when no roles exist, return the default sample roles
    return [
      'Lead Actor',
      'Supporting Actor',
      'Antagonist',
      'Comedic Relief',
      'Narrator',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: _movieData?.title ?? "Movie Details",
      ),
      endDrawer: const CustomDrawer(), // Changed from drawer to endDrawer
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Information Card
              Card(
                color: AppColors.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Movie Details',
                        style: ResponsiveText.textStyle(
                          context,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildMovieDetailRow('Title', _movieData?.title ?? 'N/A'),
                      const SizedBox(height: 10),
                      _buildMovieDetailRow('Director', _movieData?.director ?? 'N/A'),
                      const SizedBox(height: 10),
                      _buildMovieDetailRow('Budget', _movieData?.budget ?? 'N/A'),
                      // const SizedBox(height: 10),
                      // _buildMovieDetailRow('Duration', _movieData?.duration ?? 'N/A'),
                      const SizedBox(height: 10),
                      _buildMovieDetailRow('Status', _getStatusDisplayText(_movieData?.status)),
                      const SizedBox(height: 10),
                      // Use the new date formatter for the end date
                      _buildMovieDetailRow('End Date', DateFormatter.formatToDDMMYYYY(_movieData?.endDate)),
                      const SizedBox(height: 10),
                      //_buildMovieDetailRow('Cast', _movieData?.cast ?? 'N/A'),
                      const SizedBox(height: 15),
                      Text(
                        'Description',
                        style: ResponsiveText.textStyle(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _movieData?.description ?? 'No description available',
                        style: ResponsiveText.textStyle(
                          context,
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      if (_movieData?.genreList != null && _movieData!.genreList!.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Text(
                          'Genres',
                          style: ResponsiveText.textStyle(
                            context,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: _movieData!.genreList!.map((genre) => 
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                genre,
                                style: ResponsiveText.textStyle(
                                  context,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              Text(
                'Audition Information',
                style: ResponsiveText.textStyle(
                  context,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Role Selection Dropdown
              Text(
                'Select Role',
                style: ResponsiveText.textStyle(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              CustomDropdown(
                labelText: 'Select Role',
                value: _selectedRole,
                items: _getFilteredRoles(), // Use filtered roles based on user role
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // Upload Video Button
              Text(
                'Upload Audition Video',
                style: ResponsiveText.textStyle(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _selectVideo, // Changed to call _selectVideo method
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  icon: const Icon(
                    Icons.upload_file,
                    color: Colors.white,
                  ),
                  label: Text(
                    _videoName ?? 'Choose Video File', // Show selected file name or default text
                    style: ResponsiveText.textStyle(
                      context,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Notes Field
              CustomTextField(
                labelText: 'Notes (Optional)',
                controller: _notesController,
                maxLines: 3,
              ),
              
              const SizedBox(height: 40),
              
              // Submit Button
              // Show Auditions button for Casting Directors (role ID 2)
              if (_userRoleId == 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CustomAnimatedButton(
                    text: 'Show Auditions',
                    onPressed: () {
                      // Navigate to roles screen with movie data
                      Navigator.pushNamed(
                        context,
                        '/roles',
                        arguments: {
                          'movieId': _movieData?.id,
                          'movieTitle': _movieData?.title,
                          'roles': _movieData?.roles,
                        },
                      );
                    },
                    gradientStart: const Color(0xFF4CAF50),
                    gradientEnd: const Color(0xFF2E7D32),
                  ),
                ),
              CustomAnimatedButton(
                text: _isSubmitting ? 'Submitting...' : 'Pay And Submit Audition',
                onPressed: _submitAudition,
                enabled: !_isSubmitting, // Use the enabled property
                gradientStart: const Color(0xFFFF8F71),
                gradientEnd: const Color(0xFFEF2D1A),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMovieDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: ResponsiveText.textStyle(
              context,
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: ResponsiveText.textStyle(
              context,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// Add a helper function to map API status values to user-friendly labels
String _getStatusDisplayText(String? status) {
  switch (status) {
    case 'open':
      return 'active';
    case 'closed':
      return 'inactive';
    case 'upcoming':
      return 'upcoming';
    default:
      return status ?? 'N/A';
  }
}