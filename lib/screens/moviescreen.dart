import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import '../services/api_service.dart';
import '../models/getmoviemodel.dart' as movie_model;
import '../services/session_manager.dart';
import '../util/app_colors.dart';
import '../util/date_formatter.dart'; // Add this import

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  List<movie_model.GetData>? _movies = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatusFilter = 'all'; // Add status filter state

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sessionManager = SessionManager();
      final token = sessionManager.authToken;
      final userRoleId = sessionManager.userRoleId;
      
      // Use different API calls based on user role
      if (userRoleId == 3) { // Actor role
        final moviesResponse = await ApiService.getAllMoviesForActor(token: token);
        
        if (moviesResponse != null && moviesResponse.success == true) {
          setState(() {
            // Convert Allmoviemodel.Data to getmoviemodel.GetData for UI compatibility
            _movies = moviesResponse.data?.map((item) => movie_model.GetData(
              id: item.id,
              userId: item.userId,
              title: item.title,
              description: item.description,
              genre: item.genre,
              endDate: item.endDate,
              director: item.director,
              budget: item.budget,
              status: item.status,
              createdAt: item.createdAt,
              updatedAt: item.updatedAt,
              // duration: item.duration,
              cast: item.cast,
              posterUrl: item.posterUrl,
              genreList: item.genreList,
              roles: item.roles?.map((role) => movie_model.Roles(
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
            )).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = moviesResponse?.message ?? 'Failed to load movies';
            _isLoading = false;
          });
          
          // Handle unauthorized access
          if (moviesResponse?.message?.contains('Unauthorized') == true || moviesResponse?.message?.contains('token') == true) {
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
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(_errorMessage!,
                        style: const TextStyle(color: Colors.black)), // Black text
                    backgroundColor: Colors.white), // White background
              );
            }
          }
        }
      } else { // Casting Director or other roles
        final moviesResponse = await ApiService.getAllMovies(token: token);
        
        if (moviesResponse != null && moviesResponse.success == true) {
          setState(() {
            _movies = moviesResponse.data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = moviesResponse?.message ?? 'Failed to load movies';
            _isLoading = false;
          });
          
          // Handle unauthorized access
          if (moviesResponse?.message?.contains('Unauthorized') == true || moviesResponse?.message?.contains('token') == true) {
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
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(_errorMessage!,
                        style: const TextStyle(color: Colors.black)), // Black text
                    backgroundColor: Colors.white), // White background
              );
            }
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load movies';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to load movies',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
      }
    }
  }

  // Get filtered movies based on selected status
  List<movie_model.GetData> _getFilteredMovies() {
    if (_movies == null || _movies!.isEmpty) return [];
    
    if (_selectedStatusFilter == 'all') {
      return _movies!;
    }
    
    return _movies!.where((movie) {
      final status = movie.status?.toLowerCase() ?? '';
      
      // Map the status values - handle both API formats
      switch (_selectedStatusFilter) {
        case 'active':
          return status == 'open' || status == 'active';
        case 'inactive':
          return status == 'closed' || status == 'inactive';
        case 'upcoming':
          return status == 'upcoming';
        default:
          return true;
      }
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(
        title: 'Available Movies',
      ),
      endDrawer: const CustomDrawer(), // Changed from drawer to endDrawer
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          _loadMovies();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a movie to audition for:',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
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
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _loadMovies,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _getFilteredMovies().isEmpty
                            ? Center(
                                child: Text(
                                  _selectedStatusFilter == 'all'
                                      ? 'No movies available. Add a new movie to get started!'
                                      : 'No ${_selectedStatusFilter} movies found.',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.7,
                                ),
                                itemCount: _getFilteredMovies().length,
                                itemBuilder: (context, index) {
                                  final movie = _getFilteredMovies()[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/movie-detail',
                                        arguments: movie,
                                      );
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
                                              child: Center(
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
                                                  movie.title ?? 'Unknown Title',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 5),
                                                // Update this line to format the date
                                                Text(
                                                  '${movie.director ?? 'Unknown Director'} • ${DateFormatter.formatToDDMMYYYY(movie.endDate)}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white70,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 5),
                                                if (movie.genreList != null && movie.genreList!.isNotEmpty)
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
                                                      movie.genreList!.first,
                                                      style: const TextStyle(
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
      ),
    );
  }
}

// Add a helper function to map API status values to user-friendly labels
String _getStatusDisplayText(String? status) {
  switch (status) {
    case 'open':
      return 'Active';
    case 'closed':
      return 'Inactive';
    case 'upcoming':
      return 'Upcoming';
    default:
      return status ?? 'N/A';
  }
}
