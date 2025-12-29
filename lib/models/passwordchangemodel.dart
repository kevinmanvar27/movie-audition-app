class PasswordChangeModel {
  bool? success;
  List<dynamic>? data;
  String? message;

  PasswordChangeModel({
    this.success,
    this.data,
    this.message,
  });

  factory PasswordChangeModel.fromJson(Map<String, dynamic> json) {
    return PasswordChangeModel(
      success: json['success'] as bool?,
      data: json['data'] != null ? List<dynamic>.from(json['data']) : [],
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data ?? [],
      'message': message,
    };
  }
}
