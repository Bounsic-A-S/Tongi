import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiTTSService {
  static String get baseUrl {
    const endpoint =
        "https://backend-tongi.bravefield-d0689482.eastus.azurecontainerapps.io";
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      return "$endpoint/api/tts";
    } else {
      return "$endpoint/api/tts";
    }
  }

  static const Duration requestTimeout = Duration(seconds: 20);


  static Future<String> synthesizeSpeech({
    required String text,
    required String language,
    required String voice,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/synthesize");

      final body = jsonEncode({
        "text": text.trim(),
        "language": language,
        "voice": voice,
      });

      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['audio_data'] != null) {
          return data['audio_data']; // URL del archivo de audio
        } else {
          throw Exception("Respuesta sin campo 'audio_data'");
        }
      } else if (response.statusCode == 404) {
        throw Exception("Servicio TTS no encontrado. Verifica el backend.");
      } else if (response.statusCode == 500) {
        throw Exception("Error interno del servidor TTS.");
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.reasonPhrase}");
      }
    } on http.ClientException catch (e) {
      throw Exception("Error de conexión: ${e.message}");
    } on FormatException catch (e) {
      throw Exception("Error en formato de respuesta: ${e.message}");
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Tiempo de espera agotado. El servidor no respondió a tiempo.");
      }
      rethrow;
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }
}
