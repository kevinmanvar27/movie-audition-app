// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart'; // Added import for file picker
// // import '../models/audition.dart';
// import '../util/customTextformfield.dart';
// import '../util/custombutton.dart';
// import '../util/customdropdown.dart';
// import '../widgets/custom_header.dart';
// import '../widgets/custom_drawer.dart';
// import '../util/app_colors.dart';
//
// class EditAuditionScreen extends StatefulWidget {
//   //final Audition audition;
//
//   //const EditAuditionScreen({super.key, required this.audition});
//
//   @override
//   State<EditAuditionScreen> createState() => _EditAuditionScreenState();
// }
//
// class _EditAuditionScreenState extends State<EditAuditionScreen> {
//   final TextEditingController _movieController = TextEditingController();
//   final TextEditingController _roleController = TextEditingController();
//   final TextEditingController _dateController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   String? _videoPath; // To store selected video path
//   String? _videoName; // To store selected video name
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize controllers with existing audition data
//     // _movieController.text = widget.audition.movie;
//     // _roleController.text = widget.audition.role;
//     // _dateController.text = widget.audition.date;
//     //
//     // Initialize video path and name if they exist
//     _videoPath = ''; // In a real app, this would be the existing video path
//     _videoName = 'No video selected'; // In a real app, this would be the existing video name
//   }
//
//   // Validation functions
//   String? _validateMovie(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter movie name';
//     }
//     return null;
//   }
//
//   String? _validateRole(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter role name';
//     }
//     return null;
//   }
//
//   String? _validateDate(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter date';
//     }
//     return null;
//   }
//
//   // Method to handle video selection
//   Future<void> _selectVideo() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.video,
//         allowMultiple: false,
//       );
//
//       if (result != null) {
//         setState(() {
//           _videoPath = result.files.single.path;
//           _videoName = result.files.single.name;
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Selected: $_videoName',
//                   style: const TextStyle(color: Colors.black)), // Black text
//               backgroundColor: Colors.white), // White background
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Failed to pick video',
//                 style: TextStyle(color: Colors.black)), // Black text
//             backgroundColor: Colors.white), // White background
//       );
//     }
//   }
//
//   // void _updateAudition() async {
//   //   if (_formKey.currentState!.validate()) {
//   //     // Create updated audition object
//   //     final updatedAudition = Audition(
//   //       id: widget.audition.id, // Keep the same ID
//   //       title: widget.audition.title, // Keep the original title
//   //       movie: _movieController.text,
//   //       role: _roleController.text,
//   //       status: widget.audition.status, // Keep the original status
//   //       duration: widget.audition.duration, // Keep the original duration
//   //       date: _dateController.text,
//   //       thumbnail: widget.audition.thumbnail, // Keep the same thumbnail
//   //     );
//   //
//   //     // Update via API
//   //     final success = await DataService().updateUserAudition(updatedAudition);
//   //
//   //     if (success) {
//   //       // Show success message and navigate back
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Audition updated successfully!')),
//   //       );
//   //
//   //       // Return the updated audition to the previous screen
//   //       Navigator.pop(context, updatedAudition);
//   //     } else {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Failed to update audition')),
//   //       );
//   //     }
//   //   }
//   // }
//
//   void _deleteAudition() async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Audition'),
//           content: const Text('Are you sure you want to delete this audition?'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () => Navigator.of(context).pop(false),
//             ),
//             TextButton(
//               child: const Text('Delete'),
//               onPressed: () => Navigator.of(context).pop(true),
//             ),
//           ],
//         );
//       },
//     );
//
//     // if (confirmed == true) {
//     //   final success = await DataService().deleteUserAudition(widget.audition.id);
//     //
//     //   if (success) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       const SnackBar(content: Text('Audition deleted successfully!')),
//     //     );
//     //
//     //     // Navigate back with null to indicate deletion
//     //     Navigator.pop(context, null);
//     //   } else {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       const SnackBar(content: Text('Failed to delete audition')),
//     //     );
//     //   }
//     // }
//   }
//
//   @override
//   void dispose() {
//     _movieController.dispose();
//     _roleController.dispose();
//     _dateController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomHeader(
//         title: 'Edit Audition',
//       ),
//       endDrawer: CustomDrawer(),
//       backgroundColor: AppColors.background,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Edit Audition',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//
//               // Movie Field
//               CustomTextField(
//                 labelText: 'Movie *',
//                 controller: _movieController,
//                 validator: _validateMovie,
//               ),
//
//               const SizedBox(height: 20),
//
//               // Role Field
//               CustomTextField(
//                 labelText: 'Role *',
//                 controller: _roleController,
//                 validator: _validateRole,
//               ),
//
//               const SizedBox(height: 20),
//
//               // Date Field
//               CustomTextField(
//                 labelText: 'Date *',
//                 controller: _dateController,
//                 validator: _validateDate,
//               ),
//
//               const SizedBox(height: 20),
//
//               // Upload Video Button
//               const Text(
//                 'Update Audition Video',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: OutlinedButton.icon(
//                   onPressed: _selectVideo,
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.white30),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.0),
//                     ),
//                   ),
//                   icon: const Icon(
//                     Icons.upload_file,
//                     color: Colors.white,
//                   ),
//                   label: Text(
//                     _videoName ?? 'Choose Video File',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//
//               // Action Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomAnimatedButton(
//                       text: 'Delete Audition',
//                       onPressed: _deleteAudition,
//                       gradientStart: const Color(0xFF6c757d),
//                       gradientEnd: const Color(0xFF495057),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }