class UpdateStatusModel {
  bool? success;
  Data? data;
  String? message;

  UpdateStatusModel({this.success, this.data, this.message});

  UpdateStatusModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['success'] = success;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    dataMap['message'] = message;
    return dataMap;
  }
}

class Data {
  int? id;
  int? userId;
  int? movieId;
  String? role;
  String? applicantName;
  String? uploadedVideos;
  String? oldVideoBackups;
  String? notes;
  String? status;
  String? createdAt;
  String? updatedAt;
  User? user;
  Movie? movie;

  Data({
    this.id,
    this.userId,
    this.movieId,
    this.role,
    this.applicantName,
    this.uploadedVideos,
    this.oldVideoBackups,
    this.notes,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.movie,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    movieId = json['movie_id'];
    role = json['role'];
    applicantName = json['applicant_name'];
    uploadedVideos = json['uploaded_videos'];
    oldVideoBackups = json['old_video_backups'];
    notes = json['notes'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    movie = json['movie'] != null ? Movie.fromJson(json['movie']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['id'] = id;
    dataMap['user_id'] = userId;
    dataMap['movie_id'] = movieId;
    dataMap['role'] = role;
    dataMap['applicant_name'] = applicantName;
    dataMap['uploaded_videos'] = uploadedVideos;
    dataMap['old_video_backups'] = oldVideoBackups;
    dataMap['notes'] = notes;
    dataMap['status'] = status;
    dataMap['created_at'] = createdAt;
    dataMap['updated_at'] = updatedAt;
    if (user != null) {
      dataMap['user'] = user!.toJson();
    }
    if (movie != null) {
      dataMap['movie'] = movie!.toJson();
    }
    return dataMap;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  String? role;
  int? roleId;
  String? status;
  String? mobileNumber;
  String? profilePhoto;
  List<String>? imageGallery;
  String? dateOfBirth;
  String? gender;
  String? otpExpiresAt;
  int? isVerified;
  String? deviceToken;

  User({
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
    this.imageGallery,
    this.dateOfBirth,
    this.gender,
    this.otpExpiresAt,
    this.isVerified,
    this.deviceToken,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    role = json['role'];
    roleId = json['role_id'];
    status = json['status'];
    mobileNumber = json['mobile_number'];
    profilePhoto = json['profile_photo'];
    imageGallery = json['image_gallery'] != null
        ? List<String>.from(json['image_gallery'])
        : [];
    dateOfBirth = json['date_of_birth'];
    gender = json['gender'];
    otpExpiresAt = json['otp_expires_at'];
    isVerified = json['is_verified'];
    deviceToken = json['device_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['id'] = id;
    dataMap['name'] = name;
    dataMap['email'] = email;
    dataMap['email_verified_at'] = emailVerifiedAt;
    dataMap['created_at'] = createdAt;
    dataMap['updated_at'] = updatedAt;
    dataMap['role'] = role;
    dataMap['role_id'] = roleId;
    dataMap['status'] = status;
    dataMap['mobile_number'] = mobileNumber;
    dataMap['profile_photo'] = profilePhoto;
    dataMap['image_gallery'] = imageGallery;
    dataMap['date_of_birth'] = dateOfBirth;
    dataMap['gender'] = gender;
    dataMap['otp_expires_at'] = otpExpiresAt;
    dataMap['is_verified'] = isVerified;
    dataMap['device_token'] = deviceToken;
    return dataMap;
  }
}

class Movie {
  int? id;
  int? userId;
  String? title;
  String? description;
  List<String>? genre;
  String? endDate;
  String? director;
  String? budget;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? duration;
  String? cast;
  String? posterUrl;
  List<String>? genreList;

  Movie({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.genre,
    this.endDate,
    this.director,
    this.budget,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.duration,
    this.cast,
    this.posterUrl,
    this.genreList,
  });

  Movie.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    description = json['description'];
    genre = json['genre'] != null ? List<String>.from(json['genre']) : [];
    endDate = json['end_date'];
    director = json['director'];
    budget = json['budget'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    duration = json['duration'];
    cast = json['cast'];
    posterUrl = json['poster_url'];
    genreList =
    json['genre_list'] != null ? List<String>.from(json['genre_list']) : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['id'] = id;
    dataMap['user_id'] = userId;
    dataMap['title'] = title;
    dataMap['description'] = description;
    dataMap['genre'] = genre;
    dataMap['end_date'] = endDate;
    dataMap['director'] = director;
    dataMap['budget'] = budget;
    dataMap['status'] = status;
    dataMap['created_at'] = createdAt;
    dataMap['updated_at'] = updatedAt;
    dataMap['duration'] = duration;
    dataMap['cast'] = cast;
    dataMap['poster_url'] = posterUrl;
    dataMap['genre_list'] = genreList;
    return dataMap;
  }
}
