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
import '../models/getmoviemodel.dart' as get_movie_model;
import '../models/editmoviemodel.dart' as edit_movie_model;

class EditMovieScreen extends StatefulWidget {
  final edit_movie_model.EditData movie;

  const EditMovieScreen({super.key, required this.movie});

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedStatus;
  DateTime? _endDate;

  List<String> _selectedGenres = [];
  final List<CharacterRole> _characterRoles = [];

  @override
  void initState() {
    super.initState();
    print('Initializing EditMovieScreen with movie: ${widget.movie}');
    print('Movie ID: ${widget.movie.id}');
    print('Movie Title: ${widget.movie.title}');
    print('Movie Director: ${widget.movie.director}');
    print('Movie Budget: ${widget.movie.budget}');
    print('Movie Description: ${widget.movie.description}');
    print('Movie Genre List: ${widget.movie.genreList}');
    print('Movie End Date: ${widget.movie.endDate}');
    print('Movie Status: ${widget.movie.status}');
    print('Movie Roles: ${widget.movie.roles}');
    
    _titleController.text = widget.movie.title ?? '';
    _directorController.text = widget.movie.director ?? '';
    _budgetController.text = widget.movie.budget ?? '';
    _descriptionController.text = widget.movie.description ?? '';

    if (widget.movie.genreList != null && widget.movie.genreList!.isNotEmpty) {
      _selectedGenres = List.from(widget.movie.genreList!);
    } else if (widget.movie.genre != null) {
      _selectedGenres = List.from(widget.movie.genre!);
    }

    if (widget.movie.endDate != null) {
      try {
        _endDate = DateTime.parse(widget.movie.endDate!);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    if (widget.movie.status != null) {
      final normalizedStatus = widget.movie.status!.toLowerCase();

      if (normalizedStatus == 'open') {
        _selectedStatus = 'active';
      } else if (normalizedStatus == 'closed') {
        _selectedStatus = 'inactive';
      } else {
        const validStatuses = ['active', 'inactive', 'upcoming'];
        if (validStatuses.contains(normalizedStatus)) {
          _selectedStatus = normalizedStatus;
        } else {
          _selectedStatus = null;
        }
      }
    } else {
      _selectedStatus = null;
    }

    // Properly handle roles from the movie model
    print('Movie roles: ${widget.movie.roles}');
    if (widget.movie.roles != null) {
      print('Number of roles: ${widget.movie.roles!.length}');
      _characterRoles.clear();
      for (var roleData in widget.movie.roles!) {
        print('Processing role: $roleData, type: ${roleData.runtimeType}');
        
        // Extract role data based on its type
        final role = _extractRoleData(roleData);
        if (role != null) {
          print('Adding role: roleType=${role.roleType}, gender=${role.gender}, ageRange=${role.ageRange}, dialogueSample=${role.dialogueSample}, id=${role.id}');
          _characterRoles.add(role);
        }
      }
      print('Total character roles loaded: ${_characterRoles.length}');
    } else {
      print('No roles found in movie data');
    }
  }

  CharacterRole? _extractRoleData(dynamic roleData) {
    // Handle if it's the Roles model object
    if (roleData is edit_movie_model.Roles) {
      return CharacterRole(
        id: roleData.id, // Store the existing ID
        roleType: roleData.roleType ?? '',
        gender: roleData.gender ?? '',
        ageRange: roleData.ageRange ?? '',
        dialogueSample: roleData.dialogueSample ?? '',
      );
    }
    // Handle if it's a Map
    else if (roleData is Map) {
      int? id;
      String roleType = '';
      String gender = '';
      String ageRange = '';
      String dialogueSample = '';

      if (roleData is Map<String, dynamic>) {
        id = roleData['id'] as int?;
        roleType = roleData['role_type'] ?? '';
        gender = roleData['gender'] ?? '';
        ageRange = roleData['age_range'] ?? '';
        dialogueSample = roleData['dialogue_sample'] ?? '';
      } else {
        id = roleData['id'] != null ? int.tryParse(roleData['id'].toString()) : null;
        roleType = roleData['role_type']?.toString() ?? '';
        gender = roleData['gender']?.toString() ?? '';
        ageRange = roleData['age_range']?.toString() ?? '';
        dialogueSample = roleData['dialogue_sample']?.toString() ?? '';
      }

      return CharacterRole(
        id: id, // Pass the ID
        roleType: roleType,
        gender: gender,
        ageRange: ageRange,
        dialogueSample: dialogueSample,
      );
    }
    return null;
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter movie title';
    }
    return null;
  }

  String? _validateGenre(List<String> selectedGenres) {
    if (selectedGenres.isEmpty) {
      return 'Please select at least one genre';
    }
    return null;
  }

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

  String? _validatePosterUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter poster URL';
    }
    return null;
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
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _addCharacterRole() {
    setState(() {
      _characterRoles.add(CharacterRole());
    });
  }

  void _removeCharacterRole(int index) {
    setState(() {
      _characterRoles.removeAt(index);
    });
  }

  void _updateMovie() async {
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
      }

      if (_endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select an end date',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
        return;
      }

      if (widget.movie.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Movie ID is missing',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
        return;
      }

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
        final sessionManager = SessionManager();
        final token = sessionManager.authToken;
        final userId = sessionManager.userId;

        if (token == null || token.isEmpty) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Authentication required. Please log in again.',
                    style: TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
          return;
        }

        if (userId == null) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('User information missing. Please log in again.',
                    style: TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
          return;
        }

        String? apiStatus = _selectedStatus?.toLowerCase();

        if (_titleController.text.trim().isEmpty) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Movie title is required',
                    style: TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
          return;
        }

        // FIXED: Handle roles properly to prevent auto-removal
        List<Map<String, dynamic>>? rolesData;

        // If user edited roles in the form, use the new roles
        if (_characterRoles.isNotEmpty) {
          rolesData = [];
          for (var role in _characterRoles) {
            final roleMap = <String, dynamic>{
              'role_type': role.roleType,
              'gender': role.gender,
              'age_range': role.ageRange,
              'dialogue_sample': role.dialogueSample,
            };

            // Add id if it exists (for existing roles)
            if (role.id != null) {
              roleMap['id'] = role.id;
            }

            rolesData.add(roleMap);
          }
        } else {
          // If there are no roles, send empty array
          rolesData = [];
        }
        // If there are no existing roles and user didn't add any, don't send roles field

        final response = await ApiService.updateMovie(
          movieId: widget.movie.id!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          genre: genreList,
          endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
          director: _directorController.text.trim(),
          budget: _budgetController.text.trim(),
          status: apiStatus ?? '',
          roles: rolesData, // Fixed: Only send roles if explicitly provided
          token: token,
          userId: userId,
        );

        Navigator.of(context).pop();

        // More robust response handling
        if (response != null) {
          if (response.success == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(response.message ?? 'Movie updated successfully',
                      style: const TextStyle(color: Colors.black)), // Black text
                  backgroundColor: Colors.white), // White background
            );
            Navigator.of(context).pop(true); // Return true to indicate successful update
          } else {
            // Handle API-level failure (even if HTTP status was 200)
            String errorMessage = response.message ?? 'Failed to update movie. Please check your input and try again.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(errorMessage,
                      style: const TextStyle(color: Colors.black)), // Black text
                  backgroundColor: Colors.white), // White background
            );
          }
        } else {
          // Handle network or other errors
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to update movie. Please check your connection and try again.',
                    style: TextStyle(color: Colors.black)), // Black text
                  backgroundColor: Colors.white), // White background
          );
        }
      } catch (e) {
        Navigator.of(context).pop();
        print('Exception during movie update: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred while updating the movie',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
      }
    }
  }

  List<Map<String, dynamic>> _convertExistingRolesToApiFormat() {
    List<Map<String, dynamic>> rolesData = [];
    if (widget.movie.roles != null) {
      for (var roleData in widget.movie.roles!) {
        // Check if roleData is of type Roles (from the model) or Map
        if (roleData is edit_movie_model.Roles) {
          // Handle if it's the Roles model object
          rolesData.add({
            'role_type': roleData.roleType ?? '',
            'gender': roleData.gender ?? '',
            'age_range': roleData.ageRange ?? '',
            'dialogue_sample': roleData.dialogueSample ?? '',
          });
        } else if (roleData is Map<String, dynamic>) {
          rolesData.add({
            'role_type': roleData.roleType ?? '',
            'gender': roleData.gender ?? '',
            'age_range': roleData.ageRange ?? '',
            'dialogue_sample': roleData.dialogueSample ?? '',
          });
        } else if (roleData is Map) {
          rolesData.add({
            'role_type': roleData.roleType?.toString() ?? '',
            'gender': roleData.gender?.toString() ?? '',
            'age_range': roleData.ageRange?.toString() ?? '',
            'dialogue_sample': roleData.dialogueSample?.toString() ?? '',
          });
        }
      }
    }
    return rolesData;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _directorController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building EditMovieScreen, character roles count: ${_characterRoles.length}');
    for (int i = 0; i < _characterRoles.length; i++) {
      final role = _characterRoles[i];
      print('Role $i: roleType=${role.roleType}, gender=${role.gender}, ageRange=${role.ageRange}, dialogueSample=${role.dialogueSample}, id=${role.id}');
    }
    
    return Scaffold(
      appBar: CustomHeader(
        title: 'Edit Movie',
      ),
      endDrawer: CustomDrawer(),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Movie',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 30),

              CustomTextField(
                labelText: 'Movie Title *',
                controller: _titleController,
                validator: _validateTitle,
              ),

              const SizedBox(height: 20),

              MultiSelectGenreDropdown(
                labelText: 'Genre *',
                selectedGenres: _selectedGenres,
                onSelectionChanged: (selectedGenres) {
                  setState(() {
                    _selectedGenres = selectedGenres;
                  });
                },
                validator: _validateGenre,
              ),

              const SizedBox(height: 20),

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
                            : DateFormat('dd/MM/yyyy').format(_endDate!),
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

              CustomTextField(
                labelText: 'Director *',
                controller: _directorController,
                validator: _validateDirector,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                labelText: 'Budget *',
                controller: _budgetController,
                keyboardType: TextInputType.number,
                validator: _validateBudget,
              ),

              const SizedBox(height: 20),
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

              CustomTextField(
                labelText: 'Description *',
                controller: _descriptionController,
                maxLines: 3,
                validator: _validateDescription,
              ),

              const SizedBox(height: 30),

              const Text(
                'Character Roles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 10),

              ..._characterRoles.asMap().entries.map((entry) {
                int idx = entry.key;
                CharacterRole role = entry.value;
                print('Rendering role widget $idx: roleType=${role.roleType}, gender=${role.gender}, ageRange=${role.ageRange}, dialogueSample=${role.dialogueSample}, id=${role.id}');
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

              CustomAnimatedButton(
                text: 'Update Movie',
                onPressed: _updateMovie,
              ),
            ],
          ),
        ),
      ),
    );
  }
}