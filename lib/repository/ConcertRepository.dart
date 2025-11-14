import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ConcertDataModel.dart';

class ConcertRepository {

  static Future<List<ConcertDataModel>> fetchConcerts() async {

    var client = http.Client();
    List<ConcertDataModel> concerts = [];

    try {

      var response = await client.get(
        Uri.parse("https://gigmap-api.onrender.com/api/v1/concerts"),
        headers: {'Accept': 'application/json'},
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