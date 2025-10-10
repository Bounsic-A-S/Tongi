import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class STTService {
  static String get baseUrl {
    if (kIsWeb) {
      // For web development
      return "https://stt-server-app.bravefield-d0689482.eastus.azurecontainerapps.io";
    } else if (Platform.isAndroid) {
      // For Android emulator
      return "https://stt-server-app.bravefield-d0689482.eastus.azurecontainerapps.io"; // in this case my ip , so change TONGI TEAM :)
    } else if (Platform.isIOS) {
      // For iOS simulator
      return "https://stt-server-app.bravefield-d0689482.eastus.azurecontainerapps.io";
    } else {
      // For desktop or other platforms
      return "https://stt-server-app.bravefield-d0689482.eastus.azurecontainerapps.io";
    }
  }

  static const Duration requestTimeout = Duration(seconds: 15);

  static Future<String> transcribeAudio(File audioFile, {  String sourceLanguage="es-ES", // <- opcional
  required String targetLanguage}) async {
    try {
      final uri = Uri.parse("$baseUrl/transcribe/translate");

      var request = http.MultipartRequest('POST', uri)
        ..fields['source_language'] = sourceLanguage
        ..fields['target_language'] = targetLanguage
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            audioFile.path,

          ),
        );

      final streamedResponse = await request.send().timeout(requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] ?? 'Sin texto';
      } else {
        throw Exception("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (e) {
      debugPrint("❌ Error al transcribir audio: $e");
      rethrow;
    }
  }
}
