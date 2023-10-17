class PostModel {
  int? id;
  int? userId;
  String? title;
  String? description;
  String? cover;
  int? status;
  String? createdAt;
  String? updatedAt;

  PostModel(
      {this.id,
      this.userId,
      this.title,
      this.description,
      this.cover,
      this.status,
      this.createdAt,
      this.updatedAt});

  PostModel.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    userId = int.parse(json['user_id'].toString());
    title = json['title'];
    description = json['description'];
    cover = json['cover'];
    status = int.parse(json['status'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['title'] = title;
    data['description'] = description;
    data['cover'] = cover;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
