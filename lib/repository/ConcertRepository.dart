import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/ConcertDataModel.dart';
import '../services/TokenStorage.dart';

class ConcertRepository {
  static const String baseUrl = "https://gigmap-api.onrender.com/api/v1/concerts";

  static Future<Map<String, String>> _headers() async {
    String? token = await TokenStorage.getToken();

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // GET ALL CONCERTS
  static Future<List<ConcertDataModel>> fetchConcerts() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await _headers(),
      );

      List result = jsonDecode(response.body);

      return result
          .map((e) => ConcertDataModel.objJson(e))
          .toList()
          .cast<ConcertDataModel>();
    } catch (e) {
      return [];
    }
  }

  // GET CONCERT BY ID
  static Future<ConcertDataModel?> fetchConcertById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$id"),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        return ConcertDataModel.objJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // CREATE CONCERT
  static Future<ConcertDataModel?> createConcert(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _headers(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ConcertDataModel.objJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  //UPDATE CONCERT
  static Future<ConcertDataModel?> updateConcert(int id, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: await _headers(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return ConcertDataModel.objJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // DELETE CONCERT
  static Future<bool> deleteConcert(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: await _headers(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ADD ATTENDEE
  static Future<bool> addAttendee(int concertId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/attendees"),
        headers: await _headers(),
        body: jsonEncode({
          "concertId": concertId,
          "userId": userId,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // REMOVE ATTENDEE
  static Future<bool> removeAttendee(int concertId, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/attendees"),
        headers: await _headers(),
        body: jsonEncode({
          "concertId": concertId,
          "userId": userId,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // GET BY GENRE
  static Future<List<ConcertDataModel>> fetchByGenre(String genre) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/genre/$genre"),
        headers: await _headers(),
      );

      List result = jsonDecode(response.body);

      return result
          .map((e) => ConcertDataModel.objJson(e))
          .toList()
          .cast<ConcertDataModel>();
    } catch (e) {
      return [];
    }
  }

  // GET BY USER ATTENDED
  static Future<List<ConcertDataModel>> fetchByUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/attended/$userId"),
        headers: await _headers(),
      );

      List result = jsonDecode(response.body);

      return result
          .map((e) => ConcertDataModel.objJson(e))
          .toList()
          .cast<ConcertDataModel>();
    } catch (e) {
      return [];
    }
  }

  // get by artist
  static Future<List<ConcertDataModel>> fetchByArtist(int artistId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/artist/$artistId"),
        headers: await _headers(),
      );

      List result = jsonDecode(response.body);

      return result
          .map((e) => ConcertDataModel.objJson(e))
          .toList()
          .cast<ConcertDataModel>();
    } catch (e) {
      return [];
    }
  }
}
