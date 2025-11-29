class UserDataModel {
  final int id;
  final String email;
  final String username;
  final bool isArtist;
  final String? role;

  UserDataModel({
    required this.id,
    required this.email,
    required this.username,
    required this.isArtist,
    this.role,
  });

  static UserDataModel objJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      isArtist: json['isArtist'] as bool? ?? false,
      role: json['role'] as String?,
    );
  }
}
