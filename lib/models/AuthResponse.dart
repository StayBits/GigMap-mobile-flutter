class AuthResponse {
  final int id;
  final String email;
  final String username;
  final bool isArtist;
  final String? role;
  final String token;
  final String message;

  AuthResponse({
    required this.id,
    required this.email,
    required this.username,
    required this.isArtist,
    this.role,
    required this.token,
    required this.message,
  });

  static AuthResponse objJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      isArtist: json['isArtist'] as bool? ?? false,
      role: json['role'] as String?,
      token: json['token'] as String,
      message: json['message'] as String,
    );
  }
}
