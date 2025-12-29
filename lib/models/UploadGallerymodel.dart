import 'dart:convert';

class UploadGallerymodel {
  final bool success;
  final UploadData? data;
  final String? message;

  UploadGallerymodel({
    required this.success,
    this.data,
    this.message,
  });

  factory UploadGallerymodel.fromJson(Map<String, dynamic> json) {
    return UploadGallerymodel(
      success: json['success'] == true,
      data: json['data'] == null ? null : UploadData.fromJson(json['data']),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.toJson(),
    'message': message,
  };

  static UploadGallerymodel decode(String raw) =>
      UploadGallerymodel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

class UploadData {
  final List<String> gallery;

  UploadData({required this.gallery});

  factory UploadData.fromJson(Map<String, dynamic> json) {
    final raw = json['gallery'];
    final list = raw is List ? raw.cast<dynamic>() : <dynamic>[];
    final cleaned = list
        .map((e) => _cleanUrl(e?.toString() ?? ''))
        .where((s) => s.isNotEmpty)
        .toList();
    return UploadData(gallery: cleaned);
  }

  Map<String, dynamic> toJson() => {
    'gallery': gallery,
  };
}

String _cleanUrl(String s) {
  var t = s.trim();
  if (t.startsWith('"') && t.endsWith('"') && t.length >= 2) {
    t = t.substring(1, t.length - 1);
  }
  if (t.endsWith('%22')) {
    t = t.substring(0, t.length - 3);
  }
  return t;
}
