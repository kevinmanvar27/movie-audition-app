class forgetsendotpmodel {
  bool? success;
  String? message;
  int? userId;

  forgetsendotpmodel({this.success, this.message, this.userId});

  forgetsendotpmodel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = this.success;
    data['message'] = this.message;
    data['user_id'] = this.userId;
    return data;
  }
}
