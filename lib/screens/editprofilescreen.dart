import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../util/customTextformfield.dart';
import '../util/custombutton.dart';
// ignore: unused_import - kept for potential responsive text usage
import '../util/responsive_text.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
// ignore: unused_import - kept for potential profile model usage
import '../models/getprofilemodel.dart'; // Import GetProfileModel

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _profileImageUrl = '';
  bool _imageChanged = false;
  File? _profileImageFile;
  File? _compressedImageFile;
  String? _selectedGender;
  bool _isLoading = true; // Set to true as we're now loading data on init

  @override
  void initState() {
    super.initState();
    // Load user profile data when screen opens
    _loadUserProfile();
  }

  // Load user profile data from API
  Future<void> _loadUserProfile() async {
    try {
      final sessionManager = SessionManager();
      final token = sessionManager.authToken;

      if (token == null) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Authentication error. Please log in again.',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
        return;
      }

      final profileResponse = await ApiService.getProfileData(token: token);

      if (profileResponse != null && profileResponse.success == true) {
        final profileData = profileResponse.data;
        
        setState(() {
          // Populate form fields with existing profile data
          _nameController.text = profileData?.name ?? '';
          _emailController.text = profileData?.email ?? '';
          _phoneController.text = profileData?.mobileNumber ?? '';
          _dateOfBirthController.text = profileData?.dateOfBirth ?? '';
          _selectedGender = profileData?.gender;
          _profileImageUrl = profileData?.profilePhoto ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        String errorMessage = profileResponse?.message ?? 'Failed to load profile data.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(errorMessage,
                  style: const TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Exception during profile loading: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while loading profile data',
                style: TextStyle(color: Colors.black)), // Black text
            backgroundColor: Colors.white), // White background
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<File?> _compressImage(File imageFile) async {
    try {
      final originalSize = await imageFile.length();
      print('Original image size: ${originalSize / (1024 * 1024)} MB');

      if (originalSize <= 2 * 1024 * 1024) {
        return imageFile;
      }

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        '${imageFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
        quality: 80,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (compressedFile != null) {
        final File compressedImageFile = File(compressedFile.path);
        final compressedSize = await compressedImageFile.length();
        print('Compressed image size: ${compressedSize / (1024 * 1024)} MB');
        return compressedImageFile;
      }

      return null;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get values from controllers
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    // The validation ensures these are not empty
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter your name',
                style: TextStyle(color: Colors.black)), // Black text
            backgroundColor: Colors.white), // White background
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter your email',
                style: TextStyle(color: Colors.black)), // Black text
            backgroundColor: Colors.white), // White background
      );
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid email address',
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
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Saving profile..."),
            ],
          ),
        );
      },
    );

    try {
      final sessionManager = SessionManager();
      final token = sessionManager.authToken;

      if (token == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication error. Please log in again.')),
        );
        return;
      }

      // First, update profile data
      final dataResponse = await ApiService.updateProfileData(
        name: name,
        email: email,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        gender: _selectedGender,
        dateOfBirth: _dateOfBirthController.text.trim().isNotEmpty ? _dateOfBirthController.text.trim() : null,
        token: token,
      );

      if (dataResponse != null) {
        if (dataResponse.success == true) {

          String? updatedProfilePhotoUrl = sessionManager.userProfilePhoto;

          // If profile image has changed and a file is selected, update the image
          if (_imageChanged && _profileImageFile != null) {
            _compressedImageFile = await _compressImage(_profileImageFile!);

            if (_compressedImageFile != null) {
              // Use the newly created API method for updating profile photo
              final imageResponse = await ApiService.updateProfileImage(
                imageFile: _compressedImageFile!,
                token: token,
              );

              if (imageResponse != null && imageResponse.success == true) {
                // Successfully updated profile photo
                updatedProfilePhotoUrl = imageResponse.data?.profilePhoto;
              } else {
                Navigator.of(context).pop();
                String errorMessage = imageResponse?.message ?? 'Profile data saved, but failed to update image.';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(errorMessage,
                          style: const TextStyle(color: Colors.black)), // Black text
                      backgroundColor: Colors.white), // White background
                );
                return; // Stop if image update fails
              }
            } else {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Profile data saved, but failed to compress image',
                        style: TextStyle(color: Colors.black)), // Black text
                    backgroundColor: Colors.white), // White background
              );
              return; // Stop if compression fails
            }
          }

          // Update session with new user data
          // Use the data returned from the API, falling back to the local input (name/email)
          await sessionManager.saveSession(
            token: token,
            name: dataResponse.data?.name ?? name,
            email: dataResponse.data?.email ?? email,
            userId: dataResponse.data?.id ?? sessionManager.userId ?? 0,
            profilePhoto: updatedProfilePhotoUrl ?? dataResponse.data?.profilePhoto ?? sessionManager.userProfilePhoto,
            roleId: dataResponse.data?.roleId ?? sessionManager.userRoleId,
            phone: dataResponse.data?.mobileNumber ?? _phoneController.text.trim(),
          );

          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profile updated successfully!',
                    style: TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );

          if (mounted) {
            Navigator.pop(context, true);
          }

        } else {
          Navigator.of(context).pop();
          String errorMessage = dataResponse.message ?? 'Failed to update profile.';

          // Check for validation errors
          if (errorMessage.contains("Validation Error")) {
            // Extract specific validation errors if available
            errorMessage = 'Please check your input. Name and email are required.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(errorMessage,
                    style: const TextStyle(color: Colors.black)), // Black text
                backgroundColor: Colors.white), // White background
          );
        }
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update profile. Please try again.',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      print('Exception during profile update: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while updating the profile',
                style: TextStyle(color: Colors.black)), // Black text
            backgroundColor: Colors.white), // White background
      );
    }
  }


  Future<void> _pickProfileImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _profileImageUrl = result.files.single.path ?? '';
          _profileImageFile = File(_profileImageUrl);
          _imageChanged = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile image selected!',
                  style: TextStyle(color: Colors.black)), // Black text
              backgroundColor: Colors.white), // White background
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to pick image',
                style: TextStyle(color: Colors.black)), // Black text
            backgroundColor: Colors.white), // White background
      );
    }
  }

  void _removeProfileImage() {
    setState(() {
      _profileImageUrl = '';
      _profileImageFile = null;
      _imageChanged = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Profile image removed!',
              style: TextStyle(color: Colors.black)), // Black text
          backgroundColor: Colors.white), // White background
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(
        title: 'Edit Profile',
      ),
      endDrawer: CustomDrawer(),
      backgroundColor: const Color(0xFF383950),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Profile Picture with Edit Option
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _profileImageUrl.isNotEmpty
                      ? CircleAvatar(
                    radius: 60,
                    // Check if file is selected, otherwise try network image
                    backgroundImage: _profileImageFile != null
                        ? FileImage(_profileImageFile!)
                        : NetworkImage(_profileImageUrl) as ImageProvider,
                  )
                      : const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF383950),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFFF8F71),
                      child: Icon(
                        _imageChanged ? Icons.check : Icons.edit,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    onSelected: (String result) {
                      if (result == 'change') {
                        _pickProfileImage();
                      } else if (result == 'remove') {
                        _removeProfileImage();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'change',
                        child: Text('Change Photo'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'remove',
                        child: Text('Remove Photo'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Name Field (Required)
              CustomTextField(
                labelText: 'Full Name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Email Field (Required)
              CustomTextField(
                labelText: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  // Email validation regex
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Phone Number Field
              CustomTextField(
                labelText: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10, // Limit to 10 digits
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Remove any non-digit characters for validation
                    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                    if (digitsOnly.length > 10) {
                      return 'Phone number must not exceed 10 digits';
                    }
                    // Check if it contains only digits
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Phone number must contain only digits';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Date of Birth Field
              TextFormField(
                controller: _dateOfBirthController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _dateOfBirthController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // Gender Dropdown
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender != null && ['Male', 'Female', 'Other'].contains(_selectedGender) 
                               ? _selectedGender 
                               : null,
                        isExpanded: true,
                        hint: const Text('Select Gender'),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                        items: <String>['Male', 'Female', 'Other']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CustomAnimatedButton(
                  text: 'Save Changes',
                  onPressed: _saveProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}