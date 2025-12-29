class loginmodel {
  bool? success;
  loginData? data;
  String? message;

  loginmodel({this.success, this.data, this.message});

  loginmodel.fromJson(Map<String, dynamic> json) {
    success = json['success'] is bool ? json['success'] : false;
    data = json['data'] != null ? new loginData.fromJson(json['data']) : null;
    message = json['message'] is String ? json['message'] : '';
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

class loginData {
  User? user;
  String? token;

  loginData({this.user, this.token});

  loginData.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    token = json['token'] is String ? json['token'] : '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['token'] = this.token;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  Null? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  String? role;
  int? roleId;
  String? status;
  Null? mobileNumber;
  String? profilePhoto;
  Null? imageGallery;
  Null? dateOfBirth;
  Null? gender;

  User(
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
        this.gender});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : 0;
    name = json['name'] is String ? json['name'] : '';
    email = json['email'] is String ? json['email'] : '';
    emailVerifiedAt = json['email_verified_at'] is Null ? json['email_verified_at'] : null;
    createdAt = json['created_at'] is String ? json['created_at'] : '';
    updatedAt = json['updated_at'] is String ? json['updated_at'] : '';
    role = json['role'] is String ? json['role'] : '';
    roleId = json['role_id'] is int ? json['role_id'] : 0;
    status = json['status'] is String ? json['status'] : '';
    mobileNumber = json['mobile_number'] is Null ? json['mobile_number'] : null;
    
    // Process profile photo URL - unescape and format properly
    String? profilePhotoValue = json['profile_photo']?.toString();
    if (profilePhotoValue != null && profilePhotoValue.isNotEmpty && !profilePhotoValue.startsWith('http')) {
      // If it's a relative path, prepend the base URL
      if (!profilePhotoValue.startsWith('http')) {
        profilePhotoValue = 'https://movieaudition.rektech.work/storage/$profilePhotoValue';
      }
    }
    profilePhoto = profilePhotoValue;
    
    imageGallery = json['image_gallery'] is Null ? json['image_gallery'] : null;
    dateOfBirth = json['date_of_birth'] is Null ? json['date_of_birth'] : null;
    gender = json['gender'] is Null ? json['gender'] : null;
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
    return data;
  }
}
