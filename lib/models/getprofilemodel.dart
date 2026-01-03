class GetProfileModel {
  final bool? success;
  final ProfileData? data;
  final String? message;

  GetProfileModel({this.success, this.data, this.message});

  factory GetProfileModel.fromJson(Map<String, dynamic> json) {
    return GetProfileModel(
      success: json['success'] as bool?,
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

class ProfileData {
  final int? id;
  final String? name;
  final String? email;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final Role? role;
  final int? roleId;
  final String? status;
  final String? mobileNumber;
  final String? profilePhoto;
  final List<String> imageGallery;
  final String? dateOfBirth;
  final String? gender;
  final String? location; // Add location field
  final String? otpExpiresAt;
  final int? isVerified;
  final String? deviceToken;

  ProfileData({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.roleId,
    this.status,
    this.mobileNumber,
    this.profilePhoto,
    this.imageGallery = const [],
    this.dateOfBirth,
    this.gender,
    this.location, // Add location parameter
    this.otpExpiresAt,
    this.isVerified,
    this.deviceToken,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    // Process profile photo URL - unescape and format properly
    String? profilePhoto = json['profile_photo']?.toString();
    if (profilePhoto != null && profilePhoto.isNotEmpty) {
      // Unescape the URL (remove extra backslashes)
      profilePhoto = profilePhoto.replaceAll(r'\/', '/');
      // If it's a relative path, prepend the base URL
      if (!profilePhoto.startsWith('http')) {
        profilePhoto = 'https://movieaudition.rektech.work/storage/$profilePhoto';
      }
    }
    
    // Process image gallery URLs
    List<String> imageGallery = [];
    if (json['image_gallery'] is List) {
      imageGallery = (json['image_gallery'] as List).map((item) {
        String? url = item?.toString();
        if (url != null && url.isNotEmpty) {
          // Unescape the URL (remove extra backslashes)
          url = url.replaceAll(r'\/', '/');
          // Normalize multiple slashes
          url = url.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
          // If it's a relative path, prepend the base URL
          if (!url.startsWith('http')) {
            // Make sure we don't duplicate '/storage/' in the path
            if (url.startsWith('/storage/')) {
              url = 'https://movieaudition.rektech.work$url';
            } else {
              url = 'https://movieaudition.rektech.work/storage/$url';
            }
          }
          // Ensure the URL starts with https
          if (url.startsWith('http://')) {
            url = url.replaceFirst('http://', 'https://');
          }
          return url;
        }
        return '';
      }).where((s) => s.isNotEmpty).toList();
    }
    
    return ProfileData(
      id: json['id'] as int?,
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      roleId: json['role_id'] is int ? json['role_id'] as int? : int.tryParse('${json['role_id']}'),
      status: json['status']?.toString(),
      mobileNumber: json['mobile_number']?.toString(),
      profilePhoto: profilePhoto,
      imageGallery: imageGallery,
      dateOfBirth: json['date_of_birth']?.toString(),
      gender: json['gender']?.toString(),
      location: json['location']?.toString(), // Add location field
      otpExpiresAt: json['otp_expires_at']?.toString(),
      isVerified: json['is_verified'] is int ? json['is_verified'] as int? : int.tryParse('${json['is_verified']}'),
      deviceToken: json['device_token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.role != null) {
      data['role'] = this.role!.toJson();
    }
    data['role_id'] = this.roleId;
    data['status'] = this.status;
    data['mobile_number'] = this.mobileNumber;
    data['profile_photo'] = this.profilePhoto;
    data['image_gallery'] = this.imageGallery;
    data['date_of_birth'] = this.dateOfBirth;
    data['gender'] = this.gender;
    data['location'] = this.location; // Add location field
    data['otp_expires_at'] = this.otpExpiresAt;
    data['is_verified'] = this.isVerified;
    data['device_token'] = this.deviceToken;
    return data;
  }
}

class Role {
  final int? id;
  final String? name;
  final String? description;
  final List<String> permissions;
  final String? createdAt;
  final String? updatedAt;

  Role({
    this.id,
    this.name,
    this.description,
    this.permissions = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    final perms = json['permissions'];
    return Role(
      id: json['id'] is int ? json['id'] as int? : int.tryParse('${json['id']}'),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      permissions: perms is List
          ? List<String>.from(perms.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty))
          : const [],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
