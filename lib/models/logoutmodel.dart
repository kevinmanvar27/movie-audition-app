class logoutmodel {
  bool? success;
  List<Null>? data;
  String? message;

  logoutmodel({this.success, this.data, this.message});

  logoutmodel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Null>[];
      json['data'].forEach((v) {
        data!.add(null); // Since Null type, we just add null values
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      // For Null list, we can't call toJson() on null values
      data['data'] = this.data!.map((v) => null).toList();
    }
    data['message'] = this.message;
    return data;
  }
}