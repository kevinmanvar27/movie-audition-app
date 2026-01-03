class varifyotpmodel {
  bool? success;
  String? message;
  varifyData? data;

  varifyotpmodel({this.success, this.message, this.data});

  varifyotpmodel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? varifyData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class varifyData {
  User? user;
  String? accessToken;
  String? tokenType;

  varifyData({this.user, this.accessToken, this.tokenType});

  varifyData.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    accessToken = json['access_token'];
    tokenType = json['token_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['access_token'] = this.accessToken;
    data['token_type'] = this.tokenType;
    return data;
  }
}

class User {
  String? name;
  String? email;
  int? roleId;
  bool? isVerified;
  String? updatedAt;
  String? createdAt;
  int? id;

  User(
      {this.name,
        this.email,
        this.roleId,
        this.isVerified,
        this.updatedAt,
        this.createdAt,
        this.id});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    roleId = json['role_id'];
    isVerified = json['is_verified'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = this.name;
    data['email'] = this.email;
    data['role_id'] = this.roleId;
    data['is_verified'] = this.isVerified;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}