import 'dart:convert';

class GetmyauditionsModel {
  bool? success;
  Data? data;
  String? message;

  GetmyauditionsModel({this.success, this.data, this.message});

  GetmyauditionsModel.fromJson(Map<String, dynamic> json) {
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
  int? currentPage;
  // **CRITICAL FIX: Changed List<Data> to List<AuditionData>**
  List<AuditionData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  Data(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.lastPageUrl,
        this.links,
        this.nextPageUrl,
        this.path,
        this.perPage,
        this.prevPageUrl,
        this.to,
        this.total});

  Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      // **CRITICAL FIX: Initializing List<AuditionData> and using AuditionData.fromJson**
      data = <AuditionData>[];
      json['data'].forEach((v) {
        data!.add(AuditionData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      // Calling AuditionData.toJson() for each item
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class AuditionData {
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
  Movie? movie;

  AuditionData(
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
        this.movie});

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

  AuditionData.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : null;
    userId = json['user_id'] is int ? json['user_id'] : null;
    movieId = json['movie_id'] is int ? json['movie_id'] : null;
    role = json['role'] is String ? json['role'] : null;
    applicantName = json['applicant_name'] is String ? json['applicant_name'] : null;
    // Process uploaded videos URL - handle array of URLs
    print('Raw uploaded_videos from API: ${json['uploaded_videos']}');
    uploadedVideos = _processVideoUrls(json['uploaded_videos']);
    print('Processed uploadedVideos: $uploadedVideos');
    oldVideoBackups = json['old_video_backups'] is String ? json['old_video_backups'] : null;
    notes = json['notes'] is String ? json['notes'] : null;
    status = json['status'] is String ? json['status'] : null;
    createdAt = json['created_at'] is String ? json['created_at'] : null;
    updatedAt = json['updated_at'] is String ? json['updated_at'] : null;
    movie = json['movie'] != null ? Movie.fromJson(json['movie']) : null;
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
  String? duration;
  String? cast;
  String? posterUrl;
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
    final Map<String, dynamic> data = <String, dynamic>{};
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

class Links {
  String? url;
  String? label;
  int? page;
  bool? active;

  Links({this.url, this.label, this.page, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    page = json['page'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = this.url;
    data['label'] = this.label;
    data['page'] = this.page;
    data['active'] = this.active;
    return data;
  }
}