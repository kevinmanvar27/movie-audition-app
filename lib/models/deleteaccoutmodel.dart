class Deleteaccountmodel {
  bool? success;
  dynamic data; // Can be null or any type depending on API
  String? message;

  Deleteaccountmodel({this.success, this.data, this.message});

  Deleteaccountmodel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data']; // no need to parse as list if it's null or empty
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['success'] = success;
    dataMap['data'] = data;
    dataMap['message'] = message;
    return dataMap;
  }

  // Helper method to check if there are validation errors
  bool get hasValidationErrors {
    if (data is Map && data['password'] != null) {
      return true;
    }
    return false;
  }

  // Get validation error message
  String? get validationError {
    if (data is Map && data['password'] is List) {
      return data['password'].first?.toString();
    }
    return null;
  }
}