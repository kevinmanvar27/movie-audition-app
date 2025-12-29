class DeleteGalleryModel {
  bool? success;
  Data? data;
  String? message;

  DeleteGalleryModel({this.success, this.data, this.message});

  factory DeleteGalleryModel.fromJson(Map<String, dynamic> json) {
    return DeleteGalleryModel(
      success: json['success'] as bool?,
      data: json['data'] != null ? Data.fromJson(json['data'] as Map<String, dynamic>) : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (data != null) 'data': data!.toJson(),
      'message': message,
    };
  }
}

class Data {
  List<dynamic>? gallery;

  Data({this.gallery});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      gallery: json['gallery'] is List ? List<dynamic>.from(json['gallery']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (gallery != null) 'gallery': gallery,
    };
  }
}
