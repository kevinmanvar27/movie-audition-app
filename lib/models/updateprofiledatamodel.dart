class updateprofiledatamodel {
  bool? success;
  Data? data;
  String? message;

  updateprofiledatamodel({this.success, this.data, this.message});

  updateprofiledatamodel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
  String? emailVerifiedAt; // Changed from Null? to String?
  String? createdAt;
  String? updatedAt;
  String? role; // Changed from Null? to String?
  int? roleId;
  String? status; // Changed from Null? to String?
  String? mobileNumber; // Changed from Null? to String?
  String? profilePhoto; // Changed from Null? to String?
  List<dynamic>? imageGallery; // Keep as List<dynamic>?
  String? dateOfBirth; // Already corrected
  String? gender; // Already corrected
  String? otpExpiresAt; // Changed from Null? to String?
  int? isVerified;
  String? deviceToken; // Changed from Null? to String?
  String? location; // Already correct

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
        this.location});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at']?.toString(); // Ensure proper conversion
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    role = json['role']?.toString();
    roleId = json['role_id'] is int ? json['role_id'] as int? : int.tryParse('${json['role_id']}');
    status = json['status']?.toString();
    mobileNumber = json['mobile_number']?.toString();
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
    
    // Handle image_gallery properly
    if (json['image_gallery'] != null) {
      if (json['image_gallery'] is List) {
        imageGallery = List<dynamic>.from(json['image_gallery']);
      } else {
        imageGallery = [];
      }
    } else {
      imageGallery = [];
    }
    
    dateOfBirth = json['date_of_birth']?.toString();
    gender = json['gender']?.toString();
    otpExpiresAt = json['otp_expires_at']?.toString();
    isVerified = json['is_verified'] is int ? json['is_verified'] as int? : int.tryParse('${json['is_verified']}');
    deviceToken = json['device_token']?.toString();
    location = json['location']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['role'] = this.role;
    data['role_id'] = this.roleId;
    data['status'] = this.status;
    data['mobile_number'] = this.mobileNumber;
    data['profile_photo'] = this.profilePhoto;
    data['image_gallery'] = this.imageGallery;
    data['date_of_birth'] = this.dateOfBirth;
    data['gender'] = this.gender;
    data['otp_expires_at'] = this.otpExpiresAt;
    data['is_verified'] = this.isVerified;
    data['device_token'] = this.deviceToken;
    data['location'] = this.location;
    return data;
  }
}