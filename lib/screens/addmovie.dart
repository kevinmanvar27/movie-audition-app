import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../util/customTextformfield.dart';
import '../util/custombutton.dart';
import '../util/customdropdown.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/multiselect_genre_dropdown.dart';
import '../util/app_colors.dart';
import '../util/charrole.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../models/Addmoviemodel.dart';

class AddMovieScreen extends StatefulWidget {
  const AddMovieScreen({super.key});

  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  String? _selectedStatus;
  DateTime? _endDate;
  
  // Add this for multi-select genre
  List<String> _selectedGenres = [];

  // Character roles list
  final List<CharacterRole> _characterRoles = [];

  // Validation functions
  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter movie title';
    }
    return null;
  }

  // Update the genre validation function
  // String? _validateGenre(List<String> selectedGenres) {
  //   if (selectedGenres.isEmpty) {
  //     return 'Please select at least one genre';
  //   }
  //   return null;
  // }

  String? _validateEndDate(DateTime? value) {
    if (value == null) {
      return 'Please select an end date';
    }
    return null;
  }

  String? _validateDirector(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter director name';
    }
    return null;
  }

  String? _validateBudget(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter budget';
    }
    final budgetRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!budgetRegex.hasMatch(value)) {
      return 'Please enter a valid budget amount';
    }
    // Check if budget is greater than 0
    final budgetValue = double.tryParse(value);
    if (budgetValue == null || budgetValue <= 0) {
      return 'Budget must be greater than 0';
    }
    return null;
  }

  String? _validateStatus(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a status';
    }
    // Validate against allowed values (case insensitive)
    const validStatuses = ['active', 'inactive', 'upcoming'];
    if (!validStatuses.contains(value.toLowerCase())) {
      return 'Please select a valid status';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter description';
    }
    return null;
  }

  String? _validateCast(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter cast information';
    }
    return null;
  }

  String? _validateDuration(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter duration';
    }
    return null;
  }

  String? _validatePoster(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter poster URL';
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  // Add a new character role
  void _addCharacterRole() {
    setState(() {
      _characterRoles.add(CharacterRole());
    });
  }

  // Remove a character role
  void _removeCharacterRole(int index) {
    setState(() {
      _characterRoles.removeAt(index);
    });
  }

  // Clear form method
  void _clearForm() {
    setState(() {
      _titleController.clear();
      _directorController.clear();
      _budgetController.clear();
      _descriptionController.clear();
      _genreController.clear();
      _selectedGenres.clear();
      _endDate = null;
      _selectedStatus = null;
      _characterRoles.clear();
    });
  }

  // Add this validation function for character roles
  String? _validateCharacterRoles(List<CharacterRole> roles) {
    if (roles.isEmpty) {
      return 'At least one character role is required';
    }
    
    // Check if any role has empty fields
    for (var role in roles) {
      if (role.roleType.isEmpty || role.gender.isEmpty || role.ageRange.isEmpty || role.dialogueSample.isEmpty) {
        return 'Please fill in all fields for all character roles';
      }
    }
    
    return null;
  }

  // Enhanced _submitMovie function with improved error handling and validation
  void _submitMovie() async {
    if (_formKey.currentState!.validate()) {
      // Validate that at least one character role is defined
      if (_characterRoles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('At least one character role is required',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
        return;
      }
      
      // Validate character roles - check if all fields are filled
      for (var role in _characterRoles) {
        if (role.roleType.isEmpty || role.gender.isEmpty || role.ageRange.isEmpty || role.dialogueSample.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please fill in all fields for all character roles',
                    style: TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
          return;
        }
        
        // Validate age range format (must be X-Y format, e.g., 20-30)
        final ageRangeRegex = RegExp(r'^\d+-\d+$');
        if (!ageRangeRegex.hasMatch(role.ageRange)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Age range must be in format 20-30 for role: ${role.roleType}',
                    style: const TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
          return;
        }
        
        // Validate that minimum age is less than maximum age
        final parts = role.ageRange.split('-');
        final minAge = int.tryParse(parts[0]);
        final maxAge = int.tryParse(parts[1]);
        if (minAge != null && maxAge != null && minAge >= maxAge) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Minimum age must be less than maximum age for role: ${role.roleType}',
                    style: const TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
          return;
        }
      }

      // Prepare genre list from selected genres
      final List<String> genreList = _selectedGenres.isNotEmpty 
          ? _selectedGenres 
          : _genreController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      // Validate that we have at least one genre - show snackbar if empty
      if (genreList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select at least one genre',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
        return;
      }

      // Validate that we have an end date
      if (_endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select an end date',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF2D1A)),
            ),
          );
        },
      );

      try {
        // Get token and user ID from session manager
        final sessionManager = SessionManager();
        final token = sessionManager.authToken;
        final userId = sessionManager.userId;

        // Validate that we have a token
        if (token == null || token.isEmpty) {
          Navigator.of(context).pop(); // Hide loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Authentication required. Please log in again.',
                    style: TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
          return;
        }

        if (userId == null) {
          Navigator.of(context).pop(); // Hide loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('User information missing. Please log in again.',
                    style: TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
          return;
        }

        // Ensure the status is in lowercase as required by the API
        String? apiStatus = _selectedStatus?.toLowerCase();

        // Prepare character roles data for API
        List<Map<String, dynamic>> rolesData = [];
        for (var role in _characterRoles) {
          rolesData.add({
            'role_type': role.roleType,
            'gender': role.gender,
            'age_range': role.ageRange,
            'dialogue_sample': role.dialogueSample,
          });
        }

        // Call the API service to add the movie
        final response = await ApiService.addMovie(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          genre: genreList,
          endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
          director: _directorController.text.trim(),
          budget: _budgetController.text.trim(),
          status: apiStatus ?? '', // Use the lowercase status
          roles: rolesData.isNotEmpty ? rolesData : null, // Send roles data if available
          token: token,
          userId: userId,
        );

        Navigator.of(context).pop(); // Hide loading indicator

        if (response != null && response.success == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response.message ?? 'Movie added successfully',
                    style: const TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
          
          // Clear the form
          _clearForm();
          
          // Navigate back to the previous screen or show confirmation
          // For now, we'll just show a success message
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response?.message ?? 'Failed to add movie',
                    style: const TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // Hide loading indicator
        //print('Exception during movie submission: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred while adding the movie',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _directorController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    _genreController.dispose(); // Dispose genre controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(
        title: 'Add Movie',
      ),
      endDrawer: const CustomDrawer(),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Movie',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 30),

              // Title Field
              CustomTextField(
                labelText: 'Movie Title *',
                controller: _titleController,
                validator: _validateTitle,
              ),

              const SizedBox(height: 20),

              // Multi-Select Genre Dropdown (replaces the single text input)
              MultiSelectGenreDropdown(
                labelText: 'Genre *',
                selectedGenres: _selectedGenres,
                onSelectionChanged: (selectedGenres) {
                  setState(() {
                    _selectedGenres = selectedGenres;
                  });
                },
                //validator: _validateGenre,
              ),

              const SizedBox(height: 20),

              // End Date Picker
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Audition End Date *',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: AppColors.borderFocused, width: 2.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: AppColors.borderError, width: 2.0),
                    ),
                    filled: true,
                    fillColor: AppColors.textPrimary.withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _endDate == null
                            ? 'Select Date'
                            : DateFormat('dd/MM/yyyy').format(_endDate!), // Change format here
                        style: TextStyle(
                          color: _endDate == null
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Director Field
              CustomTextField(
                labelText: 'Director *',
                controller: _directorController,
                validator: _validateDirector,
              ),

              const SizedBox(height: 20),

              // Budget Field
              CustomTextField(
                labelText: 'Budget in Crore*',
                controller: _budgetController,
                keyboardType: TextInputType.number,
                validator: _validateBudget,
              ),

              const SizedBox(height: 20),
              // Active Status Dropdown (Active/Inactive)
              CustomDropdown(
                labelText: 'Status *',
                value: _selectedStatus,
                items: const ['active', 'inactive', 'upcoming'],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
                validator: _validateStatus,
              ),

              const SizedBox(height: 20),

              // Description Field
              CustomTextField(
                labelText: 'Description *',
                controller: _descriptionController,
                maxLines: 3,
                validator: _validateDescription,
              ),

              const SizedBox(height: 30),

              // Character Roles Section
              const Text(
                'Character Roles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 10),

              // Display existing character roles
              ..._characterRoles.asMap().entries.map((entry) {
                int idx = entry.key;
                CharacterRole role = entry.value;
                return CharacterRoleWidget(
                  key: Key('role_$idx'),
                  role: role,
                  onDelete: () => _removeCharacterRole(idx),
                  onUpdate: (updatedRole) {
                    setState(() {
                      _characterRoles[idx] = updatedRole;
                    });
                  },
                );
              }).toList(),

              const SizedBox(height: 20),

              // Add Role Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _addCharacterRole,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Character Role',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Submit Button
              CustomAnimatedButton(
                text: 'Add Movie',
                onPressed: _submitMovie,
              ),
            ],
          ),
        ),
      ),
    );
  }
}