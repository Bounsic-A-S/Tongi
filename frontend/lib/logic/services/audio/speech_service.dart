import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class TTSService {
  static String get baseUrl {
    if (kIsWeb) {
      // For web development
      return "https://tts-server-app.bravefield-d0689482.eastus.azurecontainerapps.io";
    } else if (Platform.isAndroid) {
      // For Android emulator
      return "https://tts-server-app.bravefield-d0689482.eastus.azurecontainerapps.io"; // in this case my ip , so change TONGI TEAM :)
    } else if (Platform.isIOS) {
      // For iOS simulator
      return "https://tts-server-app.bravefield-d0689482.eastus.azurecontainerapps.io";
    } else {
      // For desktop or other platforms
      return "https://tts-server-app.bravefield-d0689482.eastus.azurecontainerapps.io";
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
        "text": text,
        "language": language,
        "voice": voice,
      });

      final headers = {
        "Content-Type": "application/json",
      };

      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Esperamos algo como:
        // {
        //   "audio_data": "http://localhost:8002/audio/80c7c06010f34f8da0c63d800ef20e42.wav",
        //   "language": "es-ES",
        //   "voice": "es-ES-TristanMultilingualNeural",
        //   "sample_rate": 22050
        // }

        if (data['audio_data'] != null) {
          print(data['audio_data']);
          return data['audio_data']; // Devuelve la URL del audio
        } else {
          throw Exception("No se encontró 'audio_data' en la respuesta");
        }
      } else {
        throw Exception(
          "Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}",
        );
      }
    } catch (e) {
      debugPrint("❌ Error al sintetizar texto: $e");
      rethrow;
    }
  }
}
