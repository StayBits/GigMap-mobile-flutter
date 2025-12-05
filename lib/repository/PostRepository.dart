import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/PostDataModel.dart';
import '../services/TokenStorage.dart';

class PostRepository {
  static const String baseUrl = "https://gigmap-api.onrender.com/api/v1/posts";

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

  // GET: Get all posts
  static Future<List<PostDataModel>> fetchPosts() async {
    var client = http.Client();
    List<PostDataModel> posts = [];

    try {
      final response = await client.get(
        Uri.parse(baseUrl),
        headers: await _headers(),
      );

      List result = jsonDecode(response.body);

      for (var item in result) {
        posts.add(PostDataModel.fromJson(item));
      }
    } catch (e) {
      return [];
    }

    return posts;
  }


  // GET: Get post by ID

  static Future<PostDataModel?> fetchPostById(int postId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$postId"),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        return PostDataModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }


  // POST: Create a post

  static Future<PostDataModel?> createPost({
    required int communityId,
    required int userId,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final body = jsonEncode({
        "communityId": communityId,
        "userId": userId,
        "content": content,
        "imageUrl": imageUrl,
      });

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _headers(),
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PostDataModel.fromJson(jsonDecode(response.body));
      }

      return null;
    } catch (e) {
      return null;
    }
  }


  // POST: Like a post


  static Future<bool> likePost(int postId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/$postId/like?userId=$userId"),
        headers: await _headers(),
      );

      print("LIKE STATUS: ${response.statusCode}");
      print("LIKE BODY: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("LIKE ERROR: $e");
      return false;
    }
  }


  static Future<bool> unlikePost(int postId, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$postId/unlike?userId=$userId"),
        headers: await _headers(),
      );

      print("UNLIKE STATUS: ${response.statusCode}");
      print("UNLIKE BODY: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("UNLIKE ERROR: $e");
      return false;
    }
  }




  // GET by like
  static Future<List<PostDataModel>> fetchPostsLikedByUser(int userId) async {
    List<PostDataModel> posts = [];

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/liked_by/$userId"),
        headers: await _headers(),
      );

      List result = jsonDecode(response.body);

      for (var item in result) {
        posts.add(PostDataModel.fromJson(item));
      }
    } catch (e) {
      return [];
    }

    return posts;
  }


  // PUT
  static Future<PostDataModel?> updatePost({
    required int postId,
    required String content,
    String? image,
  }) async {
    try {
      final body = jsonEncode({
        "content": content,
        "image": image,
      });

      final response = await http.put(
        Uri.parse("$baseUrl/$postId"),
        headers: await _headers(),
        body: body,
      );

      if (response.statusCode == 200) {
        return PostDataModel.fromJson(jsonDecode(response.body));
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // DELETE
  static Future<bool> deletePost(int postId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$postId"),
        headers: await _headers(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
