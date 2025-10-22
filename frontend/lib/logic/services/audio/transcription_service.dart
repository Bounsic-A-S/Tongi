import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiSTTService {

  static String get baseUrl {
    if (kIsWeb) {
      return "https://backend-tongi.bravefield-d0689482.eastus.azurecontainerapps.io";
    } else if (Platform.isAndroid) {
      return "https://backend-tongi.bravefield-d0689482.eastus.azurecontainerapps.io";
    } else if (Platform.isIOS) {
      return "https://backend-tongi.bravefield-d0689482.eastus.azurecontainerapps.io";
    } else {
      return "https://backend-tongi.bravefield-d0689482.eastus.azurecontainerapps.io";
    }
  }

  static const Duration requestTimeout = Duration(seconds: 15);


  static Future<String> transcribeAudio(
    File audioFile,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    try {
      final uri = Uri.parse("$baseUrl/api/stt/transcribe");

      final request = http.MultipartRequest('POST', uri)
        ..fields['source_language'] = sourceLanguage
        ..fields['target_language'] = targetLanguage
        ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));

      final streamedResponse = await request.send().timeout(requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] ?? '';
      } else if (response.statusCode == 404) {
        throw Exception("Servicio STT no encontrado. Verifica el backend.");
      } else if (response.statusCode == 500) {
        throw Exception("Error interno del servidor STT.");
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.reasonPhrase}");
      }
    } on http.ClientException catch (e) {
      throw Exception("Error de conexión: ${e.message}");
    } on FormatException catch (e) {
      throw Exception("Error de formato en la respuesta: ${e.message}");
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Tiempo de espera agotado. El servidor no respondió a tiempo.");
      }
      rethrow;
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }


  static Future<String> transcribeAndTranslateAudio(
    File audioFile,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    try {
      final uri = Uri.parse("$baseUrl/api/stt/transcribe/translate");

      final request = http.MultipartRequest('POST', uri)
        ..fields['source_language'] = sourceLanguage
        ..fields['target_language'] = targetLanguage
        ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));

      final streamedResponse = await request.send().timeout(requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] ?? '';
      } else if (response.statusCode == 404) {
        throw Exception("Servicio STT-Translate no encontrado. Verifica el backend.");
      } else if (response.statusCode == 500) {
        throw Exception("Error interno del servidor STT-Translate.");
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.reasonPhrase}");
      }
    } on http.ClientException catch (e) {
      throw Exception("Error de conexión: ${e.message}");
    } on FormatException catch (e) {
      throw Exception("Error de formato en la respuesta: ${e.message}");
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
