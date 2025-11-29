import 'package:shared_preferences/shared_preferences.dart';
import '../models/AuthResponse.dart';
import '../models/UserDataModel.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userUsernameKey = 'user_username';
  static const String _userIsArtistKey = 'user_is_artist';
  static const String _userRoleKey = 'user_role';

  // Guardar token y datos del usuario
  static Future<void> saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, authResponse.token);
    await prefs.setInt(_userIdKey, authResponse.id);
    await prefs.setString(_userEmailKey, authResponse.email);
    await prefs.setString(_userUsernameKey, authResponse.username);
    await prefs.setBool(_userIsArtistKey, authResponse.isArtist);
    if (authResponse.role != null) {
      await prefs.setString(_userRoleKey, authResponse.role!);
    }
  }

  // Obtener token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Obtener datos del usuario guardado
  static Future<UserDataModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_userIdKey);
    final email = prefs.getString(_userEmailKey);
    final username = prefs.getString(_userUsernameKey);
    final isArtist = prefs.getBool(_userIsArtistKey);
    final role = prefs.getString(_userRoleKey);

    if (id != null && email != null && username != null && isArtist != null) {
      return UserDataModel(
        id: id,
        email: email,
        username: username,
        isArtist: isArtist,
        role: role,
      );
    }
    return null;
  }

  // Verificar si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Limpiar todos los datos de autenticación (logout)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userUsernameKey);
    await prefs.remove(_userIsArtistKey);
    await prefs.remove(_userRoleKey);
  }
}
