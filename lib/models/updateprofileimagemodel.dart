class updateprofileimagemodel {
  bool? success;
  Data? data;
  String? message;

  updateprofileimagemodel({this.success, this.data, this.message});

  // Corrected: Removed redundant 'new' keyword (good practice in modern Dart)
  updateprofileimagemodel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt; // Use dynamic or String?
  String? createdAt;
  String? updatedAt;
  Role? role;
  int? roleId;
  String? status;
  dynamic mobileNumber; // Use dynamic or String?
  String? profilePhoto;
  List<dynamic>? imageGallery; // Changed to List<dynamic>? to handle mixed types or nulls
  dynamic dateOfBirth; // Use dynamic or String?
  dynamic gender; // Use dynamic or String?
  dynamic otpExpiresAt; // Use dynamic or String?
  int? isVerified;
  dynamic deviceToken; // Use dynamic or String?
  String? location; // Add location field

  Data(
      {this.id,
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
        this.imageGallery,
        this.dateOfBirth,
        this.gender,
        this.otpExpiresAt,
        this.isVerified,
        this.deviceToken,
        this.location}); // Add location parameter

  // Corrected: Handled image_gallery deserialization
  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    role = json['role'] != null ? Role.fromJson(json['role']) : null;
    roleId = json['role_id'];
    status = json['status'];
    mobileNumber = json['mobile_number'];
    // Process profile photo URL - unescape and format properly
    String? profilePhotoValue = json['profile_photo']?.toString();
    if (profilePhotoValue != null && profilePhotoValue.isNotEmpty) {
      // Unescape the URL (remove extra backslashes)
      profilePhotoValue = profilePhotoValue.replaceAll(r'\/', '/');
      // If it's a relative path, prepend the base URL
      if (!profilePhotoValue.startsWith('http')) {
        profilePhotoValue = 'https://movieaudition.rektech.work/storage/$profilePhotoValue';
      }
    }
    profilePhoto = profilePhotoValue;

    // CORRECTION: Directly assign the list of dynamic values.
    // Assuming 'image_gallery' contains a list of nulls or other simple types
    // which do not require a separate 'fromJson' method.
    // If it contains actual image objects, you would need a new model class for them.
    if (json['image_gallery'] != null) {
      // Cast the list to List<dynamic>
      imageGallery = List<dynamic>.from(json['image_gallery']);
    } else {
      imageGallery = null;
    }

    dateOfBirth = json['date_of_birth'];
    gender = json['gender'];
    otpExpiresAt = json['otp_expires_at'];
    isVerified = json['is_verified'];
    deviceToken = json['device_token'];
    location = json['location']; // Parse location field
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

    // For List<dynamic> containing simple types/nulls, direct assignment is fine
    if (this.imageGallery != null) {
      data['image_gallery'] = this.imageGallery;
    }

    data['date_of_birth'] = this.dateOfBirth;
    data['gender'] = this.gender;
    data['otp_expires_at'] = this.otpExpiresAt;
    data['is_verified'] = this.isVerified;
    data['device_token'] = this.deviceToken;
    data['location'] = this.location; // Include location in toJson
    return data;
  }
}

class Role {
  int? id;
  String? name;
  String? description;
  List<String>? permissions;
  String? createdAt;
  String? updatedAt;

  Role(
      {this.id,
        this.name,
        this.description,
        this.permissions,
        this.createdAt,
        this.updatedAt});

  // Corrected: Removed redundant 'new' keyword
  Role.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    // Assuming permissions is always an array of strings in JSON
    if (json['permissions'] is List) {
      permissions = List<String>.from(json['permissions']);
    } else {
      permissions = null;
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['permissions'] = this.permissions;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}