import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/CommunityDataModel.dart';
import '../services/TokenStorage.dart';

class CommunityRepository {
  static const String baseUrl = "https://gigmap-api.onrender.com/api/v1/communities";

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

  static Future<List<CommunityDataModel>> fetchCommunities() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => CommunityDataModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<CommunityDataModel?> fetchCommunityById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$id"),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        return CommunityDataModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<CommunityDataModel?> createCommunity({
    required String name,
    required String description,
    required String image,
  }) async {
    try {
      final body = jsonEncode({
        "name": name,
        "description": description,
        "image": image,
      });

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _headers(),
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommunityDataModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> updateCommunity({
    required int id,
    required String name,
    required String description,
    required String image,
  }) async {
    try {
      final body = jsonEncode({
        "name": name,
        "description": description,
        "image": image,
      });

      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: await _headers(),
        body: body,
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteCommunity(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: await _headers(),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> joinCommunity({
    required int communityId,
    required int userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/$communityId/join?userId=$userId"),
        headers: await _headers(),
      );

      print("JOIN STATUS: ${response.statusCode}");
      print("JOIN BODY: ${response.body}");

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("ERROR joinCommunity: $e");
      return false;
    }
  }


  static Future<bool> leaveCommunity({
    required int communityId,
    required int userId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$communityId/leave?userId=$userId"),
        headers: await _headers(),
      );

      print("LEAVE STATUS: ${response.statusCode}");
      print("LEAVE BODY: ${response.body}");

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("ERROR leaveCommunity: $e");
      return false;
    }
  }


  static Future<List<CommunityDataModel>> fetchCommunitiesByUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/joined/$userId"),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        List result = jsonDecode(response.body);
        return result.map((e) => CommunityDataModel.fromJson(e)).toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }
}
