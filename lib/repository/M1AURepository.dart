import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/m1au/M1AUBotReply.dart';
import '../models/m1au/ChatMessage.dart';
import '../services/TokenStorage.dart';

class M1AURepository {
  static const String _baseUrl = 'https://m1au.onrender.com';

  // Timeout para evitar esperas eternas
  static const Duration _timeout = Duration(seconds: 10);

  /// Envía un mensaje al chatbot M1AU
  Future<M1AUBotReply> sendMessage({
    required String message,
    int? userId,
  }) async {
    try {
      // Preparar headers (opcional: agregar auth token si aplica)
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Si necesitas token de auth (similar a tu ConcertRepository)
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Preparar body
      final body = jsonEncode({
        'message': message,
        if (userId != null) 'userId': userId,
      });

      // Hacer request
      final response = await http
          .post(
        Uri.parse('$_baseUrl/chat'),
        headers: headers,
        body: body,
      )
          .timeout(_timeout);

      // Validar respuesta
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return M1AUBotReply.fromJson(jsonResponse);
      } else if (response.statusCode == 503) {
        throw M1AUException(
          'El servicio de M1AU está temporalmente no disponible. Intenta de nuevo en unos momentos, miau miau.',
        );
      } else {
        throw M1AUException(
          'Error al comunicarse con M1AU (${response.statusCode}). Por favor intenta nuevamente.',
        );
      }
    } on http.ClientException {
      throw M1AUException(
        'No se pudo conectar con M1AU. Verifica tu conexión a internet, miau miau.',
      );
    } on FormatException {
      throw M1AUException(
        'M1AU envió una respuesta inesperada. Por favor intenta nuevamente.',
      );
    } catch (e) {
      if (e is M1AUException) rethrow;
      throw M1AUException(
        'Ups, tuve un problema al procesar tu mensaje. Intenta nuevamente en un momento, miau miau.',
      );
    }
  }
}

/// Excepción personalizada para errores de M1AU
class M1AUException implements Exception {
  final String message;

  M1AUException(this.message);

  @override
  String toString() => message;
}