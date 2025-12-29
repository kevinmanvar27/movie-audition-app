class ApiReel {
  final int id;
  final String videoUrl;
  final String caption;
  final String fullName;
  final String username;
  final String avatarUrl;
  final String createdAt;
  final int likes;
  final int comments;
  final bool isLiked;

  ApiReel({
    required this.id,
    required this.videoUrl,
    required this.caption,
    required this.fullName,
    required this.username,
    required this.avatarUrl,
    required this.createdAt,
    required this.likes,
    required this.comments,
    required this.isLiked,
  });

  // Create ApiReel object from JSON map
  factory ApiReel.fromJson(Map<String, dynamic> json) {
    return ApiReel(
      id: json['id'] ?? 0,
      videoUrl: json['videoUrl'] ?? '',
      caption: json['caption'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      createdAt: json['createdAt'] ?? '',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  // Convert ApiReel object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoUrl': videoUrl,
      'caption': caption,
      'fullName': fullName,
      'username': username,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt,
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
    };
  }
}

class ReelsResponse {
  final bool success;
  final List<ApiReel> data;
  final String? message;

  ReelsResponse({
    required this.success,
    required this.data,
    this.message,
  });

  // Create ReelsResponse object from JSON map
  factory ReelsResponse.fromJson(Map<String, dynamic> json) {
    List<ApiReel> reels = [];
    if (json['data'] != null) {
      reels = (json['data'] as List).map((item) => ApiReel.fromJson(item)).toList();
    }

    return ReelsResponse(
      success: json['success'] ?? false,
      data: reels,
      message: json['message'],
    );
  }
}