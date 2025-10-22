import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiTranslationService {
  // Different URLs for different environments
  static String get baseUrl {
    if (kIsWeb) {
      // For web development
      return "https://backend-tongi.bravefield-d0689482.eastus.azurecontainerapps.io";
    } else if (Platform.isAndroid) {
      // For Android emulator
      return "https://backend-tongi.bravefield-d0689482.eastus.azurecontainerapps.io"; // in this case my ip , so change TONGI TEAM :)
    } else if (Platform.isIOS) {
      // For iOS simulator
      return "http://localhost:9080";
    } else {
      // For desktop or other platforms
      return "http://localhost:9080";
    }
  }

  static const Duration requestTimeout = Duration(seconds: 10);

  static Future<String> translateText(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    try {
      final uri = Uri.parse("$baseUrl/api/ttt/translate");

      final requestBody = {
        "text": text.trim(),
        "source_language": sourceLanguage,
        "target_language": targetLanguage,
        "task": "translate",
      };
      final response = await http
          .post(
            uri,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(requestBody),
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] ?? '';
      } else if (response.statusCode == 404) {
        throw Exception(
          "Servicio de traducción no encontrado. Verifica que el servidor esté ejecutándose.",
        );
      } else if (response.statusCode == 500) {
        throw Exception("Error interno del servidor de traducción.");
      } else {
        throw Exception(
          "Error HTTP ${response.statusCode}: ${response.reasonPhrase}",
        );
      }
    } on http.ClientException catch (e) {
      throw Exception(
        "Error de conexión: No se pudo conectar al servidor. ${e.message}",
      );
    } on FormatException catch (e) {
      throw Exception("Error de formato en la respuesta: ${e.message}");
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          "Tiempo de espera agotado. El servidor tardó demasiado en responder.",
        );
      }
      rethrow;
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }

  static Future<String> translateTextAzure(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    try {
      final uri = Uri.parse("$baseUrl/api/ttt/translate");

      final requestBody = {
        "text": text.trim(),
        "source_language": sourceLanguage,
        "target_language": targetLanguage,
        "task": "translate",
      };

      print("📦 Cuerpo de la petición: ${jsonEncode(requestBody)}");

      final response = await http
          .post(
            uri,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(requestBody),
          )
          .timeout(requestTimeout);


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] ?? '';
      } else if (response.statusCode == 404) {
        throw Exception(
          "Servicio de traducción no encontrado. Verifica que el servidor esté ejecutándose.",
        );
      } else if (response.statusCode == 500) {
        throw Exception("Error interno del servidor de traducción.");
      } else {
        throw Exception(
          "Error HTTP ${response.statusCode}: ${response.reasonPhrase}",
        );
      }
    } on http.ClientException catch (e) {
      throw Exception(
        "Error de conexión: No se pudo conectar al servidor. ${e.message}",
      );
    } on FormatException catch (e) {
      throw Exception("Error de formato en la respuesta: ${e.message}");
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          "Tiempo de espera agotado. El servidor tardó demasiado en responder.",
        );
      }
      rethrow;
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }

}
