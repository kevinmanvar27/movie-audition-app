class getmoviesmodel {
  bool? success;
  List<GetData>? data;
  String? message;

  getmoviesmodel({this.success, this.data, this.message});

  getmoviesmodel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <GetData>[];
      json['data'].forEach((v) {
        data!.add(GetData.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class GetData {
  int? id;
  int? userId;
  String? title;
  String? description;
  List<String>? genre;
  String? endDate;
  String? director;
  String? budget;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? duration;
  String? cast;
  String? posterUrl;
  List<String>? genreList;
  List<Roles>? roles;

  GetData(
      {this.id,
        this.userId,
        this.title,
        this.description,
        this.genre,
        this.endDate,
        this.director,
        this.budget,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.duration,
        this.cast,
        this.posterUrl,
        this.genreList,
        this.roles});

  GetData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    description = json['description'];
    genre = json['genre'].cast<String>();
    endDate = json['end_date'];
    director = json['director'];
    budget = json['budget'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    duration = json['duration'];
    cast = json['cast'];
    posterUrl = json['poster_url'];
    genreList = json['genre_list'].cast<String>();
    if (json['roles'] != null) {
      roles = <Roles>[];
      json['roles'].forEach((v) {
        roles!.add(Roles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['genre'] = this.genre;
    data['end_date'] = this.endDate;
    data['director'] = this.director;
    data['budget'] = this.budget;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['duration'] = this.duration;
    data['cast'] = this.cast;
    data['poster_url'] = this.posterUrl;
    data['genre_list'] = this.genreList;
    // FIXED: Only include roles in JSON if they exist
    if (this.roles != null) {
      data['roles'] = this.roles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Roles {
  int? id;
  int? movieId;
  String? description;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? roleType;
  String? gender;
  String? ageRange;
  String? dialogueSample;

  Roles(
      {this.id,
        this.movieId,
        this.description,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.roleType,
        this.gender,
        this.ageRange,
        this.dialogueSample,

      });

  Roles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    movieId = json['movie_id'];
    description = json['description'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    roleType = json['role_type'];
    gender = json['gender'];
    ageRange = json['age_range'];
    dialogueSample = json['dialogue_sample'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['movie_id'] = this.movieId;
    data['description'] = this.description;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['role_type'] = this.roleType;
    data['gender'] = this.gender;
    data['age_range'] = this.ageRange;
    data['dialogue_sample'] = this.dialogueSample;
    return data;
  }
}
