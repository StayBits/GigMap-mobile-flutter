class CommunityDataModel {
  final int id;
  final String name;
  final String image;
  final String description;
  final List<int> posts;
  final List<int> members;

  CommunityDataModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.posts,
    required this.members,
  });

  factory CommunityDataModel.fromJson(Map<String, dynamic> json) {
    return CommunityDataModel(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
      description: json['description'] as String,
      posts: json['posts'] != null
          ? List<int>.from(json['posts'])
          : <int>[],
      members: json['members'] != null
          ? List<int>.from(json['members'])
          : <int>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "image": image,
      "description": description,
      "posts": posts,
      "members": members,
    };
  }
}
