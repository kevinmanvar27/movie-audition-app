import 'dart:convert';

class getsubmittedauditionsmodel {
  bool? success;
  List<Data>? data;
  String? message;

  getsubmittedauditionsmodel({this.success, this.data, this.message});

  getsubmittedauditionsmodel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  int? movieId;
  String? role;
  String? applicantName;
  dynamic uploadedVideos;  // Changed to dynamic to handle both String and List
  dynamic oldVideoBackups; // Changed to dynamic to handle both String and List
  String? notes;
  String? status;
  String? createdAt;
  String? updatedAt;
  User? user;
  Movie? movie; // Added movie property

  Data(
      {this.id,
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
        this.movie}); // Added movie parameter

  // Helper method to process video URLs from API response
  static String? _processVideoUrls(dynamic videoData) {
    if (videoData == null) return null;
    
    String? videoUrl;
    
    // Handle when videoData is a string representation of an array
    if (videoData is String) {
      // Check if it looks like a JSON array string
      if (videoData.startsWith('[') && videoData.endsWith(']')) {
        try {
          // Parse the JSON array
          List<dynamic> urls = json.decode(videoData);
          if (urls.isNotEmpty) {
            videoUrl = urls[0].toString();
          }
        } catch (e) {
          // If JSON parsing fails, treat as regular string
          videoUrl = videoData;
        }
      } 
      // Special case: Handle the malformed double URL format
      // e.g., https://movieaudition.rektech.work["https://movieaudition.rektech.work/storage/..."]
      else if (videoData.contains('[') && videoData.contains('"http')) {
        RegExp doubleUrlPattern = RegExp(r'https?:\/\/[^["]*\["(https?:\/\/[^\]]*)"\]');
        Match? doubleUrlMatch = doubleUrlPattern.firstMatch(videoData);
        if (doubleUrlMatch != null && doubleUrlMatch.groupCount >= 1) {
          videoUrl = doubleUrlMatch.group(1)!;
        } else {
          // Regular string URL
          videoUrl = videoData;
        }
      }
      else {
        // Regular string URL
        videoUrl = videoData;
      }
    }
    // Handle array of video URLs
    else if (videoData is List) {
      if (videoData.isNotEmpty) {
        // Take the first video URL
        videoUrl = videoData[0].toString();
      }
    }
    
    // Process the video URL - unescape and format properly
    if (videoUrl != null && videoUrl.isNotEmpty) {
      // First unescape any escaped characters (especially escaped forward slashes)
      videoUrl = videoUrl.replaceAll(r'\\/', '/');
      videoUrl = videoUrl.replaceAll(r'\/', '/');
      
      // Handle special case where URL might have escaped quotes
      videoUrl = videoUrl.replaceAll(r'\"', '"');
      
      // Normalize multiple slashes
      videoUrl = videoUrl.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
      
      // If it's a relative path, prepend the base URL
      if (!videoUrl.startsWith('http')) {
        videoUrl = 'https://movieaudition.rektech.work$videoUrl';
      }
      
      // Ensure the URL starts with https
      if (videoUrl.startsWith('http://')) {
        videoUrl = videoUrl.replaceFirst('http://', 'https://');
      }
      
      // Additional check for URLs that start with https but have escaped characters
      if (videoUrl.startsWith('https:\/\/') || videoUrl.startsWith('http:\/\/')) {
        videoUrl = videoUrl.replaceAll(r'\/', '/');
      }
    }
    
    return videoUrl;
  }

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : null;
    userId = json['user_id'] is int ? json['user_id'] : null;
    movieId = json['movie_id'] is int ? json['movie_id'] : null;
    role = json['role'] is String ? json['role'] : null;
    applicantName = json['applicant_name'] is String ? json['applicant_name'] : null;
    uploadedVideos = _processVideoUrls(json['uploaded_videos']);
    oldVideoBackups = _processVideoUrls(json['old_video_backups']);
    notes = json['notes'] is String ? json['notes'] : null;
    status = json['status'] is String ? json['status'] : null;
    createdAt = json['created_at'] is String ? json['created_at'] : null;
    updatedAt = json['updated_at'] is String ? json['updated_at'] : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    movie = json['movie'] != null ? Movie.fromJson(json['movie']) : null; // Added movie from JSON
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['movie_id'] = this.movieId;
    data['role'] = this.role;
    data['applicant_name'] = this.applicantName;
    data['uploaded_videos'] = this.uploadedVideos;
    data['old_video_backups'] = this.oldVideoBackups;
    data['notes'] = this.notes;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.movie != null) {
      data['movie'] = this.movie!.toJson();
    }
    return data;
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
  Null? duration;
  Null? cast;
  Null? posterUrl;
  List<String>? genreList;

  Movie(
      {this.id,
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
        this.genreList});

  Movie.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    description = json['description'];
    genre = json['genre'].cast<String>();
    endDate = json['end_date'];
    director = json['director'];
    budget = json['budget'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    duration = json['duration'];
    cast = json['cast'];
    posterUrl = json['poster_url'];
    genreList = json['genre_list'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['genre'] = this.genre;
    data['end_date'] = this.endDate;
    data['director'] = this.director;
    data['budget'] = this.budget;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['duration'] = this.duration;
    data['cast'] = this.cast;
    data['poster_url'] = this.posterUrl;
    data['genre_list'] = this.genreList;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  String? role;
  int? roleId;
  String? status;
  dynamic mobileNumber;
  String? profilePhoto;
  dynamic imageGallery;
  dynamic dateOfBirth;
  dynamic gender;
  dynamic otpExpiresAt;
  int? isVerified;
  dynamic deviceToken;

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
        this.gender,
        this.otpExpiresAt,
        this.isVerified,
        this.deviceToken});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : null;
    name = json['name'] is String ? json['name'] : null;
    email = json['email'] is String ? json['email'] : null;
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'] is String ? json['created_at'] : null;
    updatedAt = json['updated_at'] is String ? json['updated_at'] : null;
    role = json['role'] is String ? json['role'] : null;
    roleId = json['role_id'] is int ? json['role_id'] : null;
    status = json['status'] is String ? json['status'] : null;
    mobileNumber = json['mobile_number'];
    // Process profile photo URL - unescape and format properly
    String? profilePhotoValue = json['profile_photo']?.toString();
    if (profilePhotoValue != null && profilePhotoValue.isNotEmpty) {
      // Unescape the URL (remove extra backslashes)
      profilePhotoValue = profilePhotoValue.replaceAll(r'\/', '/');
      // Normalize multiple slashes
      profilePhotoValue = profilePhotoValue.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
      // If it's a relative path, prepend the base URL
      if (!profilePhotoValue.startsWith('http')) {
        // Make sure we don't duplicate '/storage/' in the path
        if (profilePhotoValue.startsWith('/storage/')) {
          profilePhotoValue = 'https://movieaudition.rektech.work$profilePhotoValue';
        } else {
          profilePhotoValue = 'https://movieaudition.rektech.work/storage/$profilePhotoValue';
        }
      }
      // Ensure the URL starts with https
      if (profilePhotoValue.startsWith('http://')) {
        profilePhotoValue = profilePhotoValue.replaceFirst('http://', 'https://');
      }
    }
    profilePhoto = profilePhotoValue;
    
    // Process image gallery URLs
    imageGallery = _processGalleryUrls(json['image_gallery']);
    
    dateOfBirth = json['date_of_birth'];
    gender = json['gender'];
    otpExpiresAt = json['otp_expires_at'];
    isVerified = json['is_verified'] is int ? json['is_verified'] : null;
    deviceToken = json['device_token'];
  }
  
  // Helper method to process gallery URLs
  static List<String> _processGalleryUrls(dynamic galleryData) {
    if (galleryData == null) return [];
    
    List<String> urls = [];
    
    if (galleryData is List) {
      for (var item in galleryData) {
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
          urls.add(url);
        }
      }
    } else if (galleryData is String) {
      // Handle case where it might be a JSON string array
      try {
        List<dynamic> parsed = json.decode(galleryData);
        urls = _processGalleryUrls(parsed);
      } catch (e) {
        // If parsing fails, treat as single URL
        String? url = galleryData;
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
          urls.add(url);
        }
      }
    }
    
    return urls;
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
    return data;
  }
}