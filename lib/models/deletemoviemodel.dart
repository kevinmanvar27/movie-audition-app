class DeleteMovieModel {
  bool? success;
  List<dynamic>? data;
  String? message;

  DeleteMovieModel({this.success, this.data, this.message});

  DeleteMovieModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <dynamic>[];
      json['data'].forEach((v) {
        data!.add(v);
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v).toList();
    }
    data['message'] = this.message;
    return data;
  }
}
