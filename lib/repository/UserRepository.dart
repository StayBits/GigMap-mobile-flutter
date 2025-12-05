import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/UserDataModel.dart';
import '../services/TokenStorage.dart';

class UserRepository {
  static const String baseUrl = "https://gigmap-api.onrender.com/api/v1/users";

  static Future<Map<String, String>> _headers() async {
    String? token = await TokenStorage.getToken();

    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }


  // GET: All users
  static Future<List<UserDataModel>> fetchUsers() async {
    List<UserDataModel> users = [];

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await _headers(),
      );

      List result = jsonDecode(response.body);

      for (var item in result) {
        users.add(UserDataModel.objJson(item));
      }
    } catch (e) {
      return [];
    }

    return users;
  }


  // GET: User by ID

  static Future<UserDataModel?> fetchUserById(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$userId"),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        return UserDataModel.objJson(jsonDecode(response.body));
      }

      return null;
    } catch (e) {
      return null;
    }
  }


  // GET: User details by ID
  static Future<Map<String, dynamic>?> fetchUserDetails(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$userId/details"),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }


  // PUT: Update user

  static Future<UserDataModel?> updateUser({
    required int userId,
    required String email,
    required String username,
    required bool isArtist,
    required String name,
    required String image,
    String? role,
  }) async {
    try {
      final body = jsonEncode({
        "email": email,
        "username": username,
        "isArtist": isArtist,
        "role": role,
      });

      final response = await http.put(
        Uri.parse("$baseUrl/$userId"),
        headers: await _headers(),
        body: body,
      );

      if (response.statusCode == 200) {
        return UserDataModel.objJson(jsonDecode(response.body));
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
