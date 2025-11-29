import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/AuthResponse.dart';

class AuthRepository {
  static const String _baseUrl = "https://gigmap-api.onrender.com/api/v1";

  // Método para registro de usuario
  static Future<AuthResponse?> register({
    required String email,
    required String username,
    required String password,
    required String role,
  }) async {
    var client = http.Client();

    try {
      var response = await client.post(
        Uri.parse("$_baseUrl/auth/register"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        // Registro exitoso
        Map<String, dynamic> result = jsonDecode(response.body);
        return AuthResponse.objJson(result);
      } else {
        // Error en el registro
        print('Error en registro: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error de conexión en registro: $e');
      return null;
    } finally {
      client.close();
    }
  }

  // Método para login de usuario
  static Future<AuthResponse?> login({
    required String emailOrUsername,
    required String password,
  }) async {
    var client = http.Client();

    try {
      var response = await client.post(
        Uri.parse("$_baseUrl/auth/login"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'emailOrUsername': emailOrUsername,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Login exitoso
        Map<String, dynamic> result = jsonDecode(response.body);
        return AuthResponse.objJson(result);
      } else {
        // Error en login
        print('Error en login: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error de conexión en login: $e');
      return null;
    } finally {
      client.close();
    }
  }
}
