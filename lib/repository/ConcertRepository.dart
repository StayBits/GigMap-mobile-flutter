import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ConcertDataModel.dart';
import '../services/TokenStorage.dart';

class ConcertRepository {

  static Future<List<ConcertDataModel>> fetchConcerts() async {

    var client = http.Client();
    List<ConcertDataModel> concerts = [];

    try {
      // Obtener token JWT
      String? token = await TokenStorage.getToken();

      // Preparar headers con token si existe
      Map<String, String> headers = {
        'Accept': 'application/json'
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      var response = await client.get(
        Uri.parse("https://gigmap-api.onrender.com/api/v1/concerts"),
        headers: headers,
      );

      List result = jsonDecode(response.body);

      for (int i = 0; i < result.length; i++) {
        ConcertDataModel c =
        ConcertDataModel.objJson(result[i] as Map<String, dynamic>);
        concerts.add(c);
      }

      return concerts;
    } catch (e) {
      return [];
    }

  }

}