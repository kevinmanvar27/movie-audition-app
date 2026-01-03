import 'dart:convert';
//
// class addauditionsmodel {
//   bool? success;
//   Data? data;
//   String? message;
//
//   addauditionsmodel({this.success, this.data, this.message});
//
//   addauditionsmodel.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     data = json['data'] != null ? Data.fromJson(json['data']) : null;
//     message = json['message'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['success'] = this.success;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     data['message'] = this.message;
//     return data;
//   }
// }
//
// class Data {
//   int? id;
//   int? userId;
//   int? movieId;
//   String? role;
//   String? applicantName;
//   dynamic uploadedVideos;  // Changed to dynamic to handle both String and List
//   dynamic oldVideoBackups; // Changed to dynamic to handle both String and List
//   String? notes;
//   String? status;
//   String? createdAt;
//   String? updatedAt;
//
//   Data(
//       {this.id,
//         this.userId,
//         this.movieId,
//         this.role,
//         this.applicantName,
//         this.uploadedVideos,
//         this.oldVideoBackups,
//         this.notes,
//         this.status,
//         this.createdAt,
//         this.updatedAt});
//
//   // Helper method to process video URLs from API response
//   static String? _processVideoUrls(dynamic videoData) {
//     if (videoData == null) return null;
//
//     String? videoUrl;
//
//     // Handle when videoData is a string representation of an array
//     if (videoData is String) {
//       // Check if it looks like a JSON array string
//       if (videoData.startsWith('[') && videoData.endsWith(']')) {
//         try {
//           // Parse the JSON array
//           List<dynamic> urls = json.decode(videoData);
//           if (urls.isNotEmpty) {
//             videoUrl = urls[0].toString();
//           }
//         } catch (e) {
//           // If JSON parsing fails, treat as regular string
//           videoUrl = videoData;
//         }
//       }
//       // Special case: Handle the malformed double URL format
//       // e.g., https://movieaudition.rektech.work["https://movieaudition.rektech.work/storage/..."]
//       else if (videoData.contains('[') && videoData.contains('"http')) {
//         RegExp doubleUrlPattern = RegExp(r'https?:\/\/[^["]*\["(https?:\/\/[^\]]*)"\]');
//         Match? doubleUrlMatch = doubleUrlPattern.firstMatch(videoData);
//         if (doubleUrlMatch != null && doubleUrlMatch.groupCount >= 1) {
//           videoUrl = doubleUrlMatch.group(1)!;
//         } else {
//           // Regular string URL
//           videoUrl = videoData;
//         }
//       }
//       else {
//         // Regular string URL
//         videoUrl = videoData;
//       }
//     }
//     // Handle array of video URLs
//     else if (videoData is List) {
//       if (videoData.isNotEmpty) {
//         // Take the first video URL
//         videoUrl = videoData[0].toString();
//       }
//     }
//
//     // Process the video URL - unescape and format properly
//     if (videoUrl != null && videoUrl.isNotEmpty) {
//       // First unescape any escaped characters (especially escaped forward slashes)
//       videoUrl = videoUrl.replaceAll(r'\\/', '/');
//       videoUrl = videoUrl.replaceAll(r'\/', '/');
//
//       // Handle special case where URL might have escaped quotes
//       videoUrl = videoUrl.replaceAll(r'\"', '"');
//
//       // Normalize multiple slashes
//       videoUrl = videoUrl.replaceAll(RegExp(r'([^:])/{2,}'), r'$1/');
//
//       // If it's a relative path, prepend the base URL
//       if (!videoUrl.startsWith('http')) {
//         videoUrl = 'https://movieaudition.rektech.work$videoUrl';
//       }
//
//       // Ensure the URL starts with https
//       if (videoUrl.startsWith('http://')) {
//         videoUrl = videoUrl.replaceFirst('http://', 'https://');
//       }
//
//       // Additional check for URLs that start with https but have escaped characters
//       if (videoUrl.startsWith('https:\/\/') || videoUrl.startsWith('http:\/\/')) {
//         videoUrl = videoUrl.replaceAll(r'\/', '/');
//       }
//     }
//
//     return videoUrl;
//   }
//
//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'] is int ? json['id'] : null;
//     userId = json['user_id'] is int ? json['user_id'] : null;
//     movieId = json['movie_id'] is int ? json['movie_id'] : null;
//     role = json['role'] is String ? json['role'] : null;
//     applicantName = json['applicant_name'] is String ? json['applicant_name'] : null;
//     uploadedVideos = _processVideoUrls(json['uploaded_videos']);
//     oldVideoBackups = _processVideoUrls(json['old_video_backups']);
//     notes = json['notes'] is String ? json['notes'] : null;
//     status = json['status'] is String ? json['status'] : null;
//     createdAt = json['created_at'] is String ? json['created_at'] : null;
//     updatedAt = json['updated_at'] is String ? json['updated_at'] : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['movie_id'] = this.movieId;
//     data['role'] = this.role;
//     data['applicant_name'] = this.applicantName;
//     data['uploaded_videos'] = this.uploadedVideos;
//     data['old_video_backups'] = this.oldVideoBackups;
//     data['notes'] = this.notes;
//     data['status'] = this.status;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }

class addauditionsmodel {
  bool? success;
  Data? data;
  String? message;

  addauditionsmodel({this.success, this.data, this.message});

  addauditionsmodel.fromJson(Map<String, dynamic> json) {
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
  int? userId;
  int? movieId;
  String? role;
  String? applicantName;
  dynamic uploadedVideos;
  dynamic oldVideoBackups;
  String? notes;
  String? status;
  String? createdAt;
  String? updatedAt;

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
        this.updatedAt});

  // Helper method to process video URLs - FOR ADD AUDITION
  // Only handles uploadedVideos, oldVideoBackups should be null for new auditions
  static String? _processVideoUrls(dynamic videoData, {bool isOldVideoBackups = false}) {
    if (videoData == null) return null;

    String? videoUrl;

    // For add audition, we only process uploadedVideos
    if (!isOldVideoBackups) {
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
    // For add audition, oldVideoBackups should be null or empty
    oldVideoBackups = null;
    notes = json['notes'] is String ? json['notes'] : null;
    status = json['status'] is String ? json['status'] : null;
    createdAt = json['created_at'] is String ? json['created_at'] : null;
    updatedAt = json['updated_at'] is String ? json['updated_at'] : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    return data;
  }
}