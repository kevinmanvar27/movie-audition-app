class deleteauditionmodel {
  bool? success;
  // Changed List<Null> to List<dynamic> to handle empty lists or potential future data safely
  List<dynamic>? data;
  String? message;

  deleteauditionmodel({this.success, this.data, this.message});

  deleteauditionmodel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <dynamic>[];
      json['data'].forEach((v) {
        // Since we don't know the structure of the data inside the list (or it's empty),
        // we just add the value directly.
        data!.add(v);
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = this.success;
    if (this.data != null) {
      // We map the list directly. If the items inside eventually have .toJson(),
      // you would need a specific model class instead of dynamic.
      data['data'] = this.data;
    }
    data['message'] = this.message;
    return data;
  }
}
