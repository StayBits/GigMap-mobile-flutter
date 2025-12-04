import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = "dngk5bc3p";
  static const String uploadPreset = "cloudinary_staymap";

  static Future<String?> uploadImage(File imageFile) async {
    final url =
    Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest("POST", url)
      ..fields["upload_preset"] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final json = jsonDecode(await response.stream.bytesToString());
      return json["secure_url"]; // secure https URL
    } else {
      return null;
    }
  }
}
