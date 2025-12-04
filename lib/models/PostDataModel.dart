class PostDataModel {
  final int id;
  final int communityId;
  final int userId;
  final String content;
  final String? image;
  final List<int> likes;

  PostDataModel({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.content,
    this.image,
    required this.likes,
  });

  factory PostDataModel.fromJson(Map<String, dynamic> json) {
    return PostDataModel(
      id: json['id'] as int,
      communityId: json['communityId'] as int,
      userId: json['userId'] as int,
      content: json['content'] as String,
      image: json['image'] as String?,
      likes: json['likes'] != null
          ? List<int>.from(json['likes'])
          : <int>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "communityId": communityId,
      "userId": userId,
      "content": content,
      "image": image,
      "likes": likes,
    };
  }
}