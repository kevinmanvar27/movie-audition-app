class sendotpmodel {
  bool? success;
  String? message;
  String? tempToken; // Temp token is directly in the response

  sendotpmodel({this.success, this.message, this.tempToken});

  sendotpmodel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    tempToken = json['temp_token']; // Directly access temp_token from response
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = this.success;
    data['message'] = this.message;
    data['temp_token'] = this.tempToken;
    return data;
  }
}
