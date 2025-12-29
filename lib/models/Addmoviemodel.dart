class AddMovieModel {
  bool? success;
  AddData? data;
  String? message;

  AddMovieModel({this.success, this.data, this.message});

  AddMovieModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new AddData.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class AddData {
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
  Null duration;
  Null cast;
  Null posterUrl;
  List<String>? genreList;
  List<Roles>? roles;

  AddData(
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

  AddData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    description = json['description'];
    // Handle genre parsing with error checking
    if (json['genre'] != null) {
      if (json['genre'] is List) {
        genre = json['genre'].cast<String>();
      } else {
        // Handle case where genre might be a string or other type
        genre = [json['genre'].toString()];
      }
    }
    endDate = json['end_date'];
    director = json['director'];
    budget = json['budget'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    duration = json['duration'];
    cast = json['cast'];
    posterUrl = json['poster_url'];
    // Handle genreList parsing with error checking
    if (json['genre_list'] != null) {
      if (json['genre_list'] is List) {
        genreList = json['genre_list'].cast<String>();
      } else {
        // Handle case where genre_list might be a string or other type
        genreList = [json['genre_list'].toString()];
      }
    }
    if (json['roles'] != null) {
      roles = <Roles>[];
      json['roles'].forEach((v) {
        roles!.add(new Roles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    if (this.roles != null) {
      data['roles'] = this.roles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Roles {
  int? id;
  int? movieId;
  Null description;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
