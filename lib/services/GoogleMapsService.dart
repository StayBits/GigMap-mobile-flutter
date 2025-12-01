import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleMapsService {
  static const String apiKey = "AIzaSyAd-IuCKmGRzA4BsS2Yz_hR5FD6-XHUqjA";

  static Future<Map<String, double>?> getLatLngFromAddress(String address) async {
    final encoded = Uri.encodeComponent(address);
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=$encoded&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final body = jsonDecode(response.body);

      if (body["status"] == "OK") {
        final location =
        body["results"][0]["geometry"]["location"];

        return {
          "lat": location["lat"],
          "lng": location["lng"],
        };
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
