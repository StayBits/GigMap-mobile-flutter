class UserDataModel {
  final int id;
  final String email;
  final String username;
  final String name;
  final String role;
  final String image;
  final bool isArtist;

  UserDataModel({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.role,
    required this.image,
    required this.isArtist,
  });

  factory UserDataModel.objJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? "",
      username: json['username'] ?? "",
      name: json['name'] ?? "",
      role: (json['role'] ?? "").toString(),
      image: (json['image'] ?? "").toString(),
      isArtist: ((json['role'] ?? "").toString().toUpperCase() == "ARTIST"),
    );
  }
}
