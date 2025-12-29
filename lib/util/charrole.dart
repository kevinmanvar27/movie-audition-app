import 'package:flutter/material.dart';

import 'customTextformfield.dart';
import 'customdropdown.dart';

class CharacterRole {
  String roleType;
  String gender;
  String ageRange;
  String dialogueSample;
  int? id; // નવું ઍડ કરેલું


  CharacterRole({
    this.roleType = '',
    this.gender = '',
    this.ageRange = '',
    this.dialogueSample = '',
    this.id, // નવું ઍડ કરેલું

  });
}

// Character Role Widget
class CharacterRoleWidget extends StatefulWidget {
  final CharacterRole role;
  final VoidCallback onDelete;
  final Function(CharacterRole) onUpdate;

  const CharacterRoleWidget({
    super.key,
    required this.role,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<CharacterRoleWidget> createState() => _CharacterRoleWidgetState();
}

class _CharacterRoleWidgetState extends State<CharacterRoleWidget> {
  late TextEditingController _roleTypeController;
  late TextEditingController _ageRangeController;
  late TextEditingController _dialogueSampleController;

  @override
  void initState() {
    super.initState();
    _roleTypeController = TextEditingController(text: widget.role.roleType);
    _ageRangeController = TextEditingController(text: widget.role.ageRange);
    _dialogueSampleController = TextEditingController(text: widget.role.dialogueSample);
    // Note: Gender is handled by the dropdown widget, not a text controller
  }

  @override
  void didUpdateWidget(covariant CharacterRoleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update text controllers if role data has changed
    if (oldWidget.role.roleType != widget.role.roleType) {
      _roleTypeController.text = widget.role.roleType;
    }
    if (oldWidget.role.ageRange != widget.role.ageRange) {
      _ageRangeController.text = widget.role.ageRange;
    }
    if (oldWidget.role.dialogueSample != widget.role.dialogueSample) {
      _dialogueSampleController.text = widget.role.dialogueSample;
    }
  }

  @override
  void dispose() {
    _roleTypeController.dispose();
    _ageRangeController.dispose();
    _dialogueSampleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building CharacterRoleWidget: roleType=${widget.role.roleType}, gender=${widget.role.gender}, ageRange=${widget.role.ageRange}, dialogueSample=${widget.role.dialogueSample}');
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Character Role',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Color(0xFFEF2D1A)),
                onPressed: widget.onDelete,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Role Type Text Field (changed from dropdown to text field)
          CustomTextField(
            labelText: 'Role Type',
            controller: _roleTypeController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter role type';
              }
              // Validate that only text (letters and spaces) are allowed, no numbers
              final textOnlyRegex = RegExp(r'^[a-zA-Z\s]+$');
              if (!textOnlyRegex.hasMatch(value)) {
                return 'Role type should only contain letters and spaces';
              }
              return null;
            },
            onChanged: (value) {
              widget.role.roleType = value;
              widget.onUpdate(widget.role);
            },
          ),
          const SizedBox(height: 15),
          // Gender Dropdown
          CustomDropdown(
            labelText: 'Gender',
            value: widget.role.gender.isEmpty ? null : widget.role.gender,
            items: const ['Male', 'Female', 'Other'],
            onChanged: (value) {
              setState(() {
                widget.role.gender = value ?? '';
                widget.onUpdate(widget.role);
              });
            },
          ),
          const SizedBox(height: 15),
          // Age Range
          CustomTextField(
            labelText: 'Age Range (e.g., 20-30) *',
            controller: _ageRangeController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter age range';
              }
              // Validate format: number-number (e.g., 20-30)
              final ageRangeRegex = RegExp(r'^\d+-\d+$');
              if (!ageRangeRegex.hasMatch(value)) {
                return 'Age range must be in format: 20-30';
              }
              // Validate that first number is less than second number
              final parts = value.split('-');
              final minAge = int.tryParse(parts[0]);
              final maxAge = int.tryParse(parts[1]);
              if (minAge != null && maxAge != null && minAge >= maxAge) {
                return 'Minimum age must be less than maximum age';
              }
              return null;
            },
            onChanged: (value) {
              widget.role.ageRange = value;
              widget.onUpdate(widget.role);
            },
          ),
          const SizedBox(height: 15),
          // Dialogue Sample
          CustomTextField(
            labelText: 'Dialogue Sample',
            controller: _dialogueSampleController,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter dialogue sample';
              }
              return null;
            },
            onChanged: (value) {
              widget.role.dialogueSample = value;
              widget.onUpdate(widget.role);
            },
          ),
        ],
      ),
    );
  }
}