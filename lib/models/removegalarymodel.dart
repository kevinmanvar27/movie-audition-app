class RemoveGalleryModel {
  bool? success;
  Data? data;
  String? message;

  RemoveGalleryModel({this.success, this.data, this.message});

  factory RemoveGalleryModel.fromJson(Map<String, dynamic> json) {
    return RemoveGalleryModel(
      success: json['success'] as bool?,
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

class Data {
  List<String>? gallery;

  Data({this.gallery});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      gallery: json['gallery'] != null
          ? List<String>.from(json['gallery'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gallery': gallery ?? [],
    };
  }
}
