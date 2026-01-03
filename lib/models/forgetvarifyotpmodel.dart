class forgetvarifyotpmodel {
  bool? success;
  String? message;
  String? resetToken;

  forgetvarifyotpmodel({this.success, this.message, this.resetToken});

  forgetvarifyotpmodel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    resetToken = json['reset_token']; // This should match the API response
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = this.success;
    data['message'] = this.message;
    data['reset_token'] = this.resetToken;
    return data;
  }
}