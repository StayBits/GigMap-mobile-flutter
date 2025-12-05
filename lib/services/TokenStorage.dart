import 'package:shared_preferences/shared_preferences.dart';
import '../models/AuthResponse.dart';
import '../models/UserDataModel.dart';

class TokenStorage {
  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userUsernameKey = 'user_username';
  static const String _userRoleKey = 'user_role';
  static const String _userImageKey = 'user_image';
  static const String _userNameKey = 'user_name';

  static Future<void> saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, authResponse.token);
    await prefs.setInt(_userIdKey, authResponse.id);
    await prefs.setString(_userEmailKey, authResponse.email);
    await prefs.setString(_userUsernameKey, authResponse.username);

    // role puede ser null en register → prevenir errores
    await prefs.setString(_userRoleKey, authResponse.role ?? "");
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<UserDataModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getInt(_userIdKey);
    final email = prefs.getString(_userEmailKey);
    final username = prefs.getString(_userUsernameKey);

    if (id == null || email == null || username == null) {
      return null;
    }

    final role = prefs.getString(_userRoleKey) ?? "";
    final image = prefs.getString(_userImageKey) ?? "";
    final name = prefs.getString(_userNameKey) ?? "";

    return UserDataModel(
      id: id,
      email: email,
      username: username,
      name: name,
      role: role,
      image: image,
      isArtist: role.toUpperCase() == "ARTIST",
    );
  }

  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }
}
