import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:frontend/logic/controllers/lang_selector_controller.dart';
import 'package:frontend/logic/services/audio/transcription_service.dart';

class STTController {
  final LangSelectorController langSelectorController = LangSelectorController();
  int _lastSTTId = 0;
  bool isTranscribing = false;
  static const Map<String, String> _languageRegions = {
    'es': 'es-ES',       // Español (España)
    'en': 'en-US',       // Inglés (Estados Unidos)
    'fr': 'fr-FR',       // Francés (Francia)
    'de': 'de-DE',       // Alemán (Alemania)
    'it': 'it-IT',       // Italiano (Italia)
    'pt': 'pt-PT',       // Portugués (Portugal)
    'zh-Hans': 'zh-CN',  // Chino simplificado (China)
    'zh-Hant': 'zh-TW',  // Chino tradicional (Taiwán)
    'ja': 'ja-JP',       // Japonés (Japón)
    'ko': 'ko-KR',       // Coreano (Corea del Sur)
    'ar': 'ar-SA',       // Árabe (Arabia Saudita)
    'ru': 'ru-RU',       // Ruso (Rusia)
    'hi': 'hi-IN',       // Hindi (India)
  };


  int getLastId() => _lastSTTId;
  void resetId() => _lastSTTId = 0;

  Future<String> transcribeAudio(File audioFile, {int id = 0}) async {
    isTranscribing = true;
    String resultText;
    try {
      final transcription = await ApiSTTService.transcribeAudio(
        audioFile,
        _languageRegions[langSelectorController.getInputLang()] ?? "es-ES",
        _languageRegions[langSelectorController.getOutputLang()] ?? "en-US"
      );

      resultText = transcription;

      if (id > _lastSTTId) {
        isTranscribing = false;
        _lastSTTId = id;
      }
    } catch (e) {
      debugPrint("❌ Error en transcribeAudio: $e");
      resultText = 'Error en la transcripción';
      isTranscribing = false;
    }

    return resultText;
  }

  Future<String> transcribeAndTranslate(File audioFile, {int id = 0}) async {
    isTranscribing = true;
    String resultText;

    try {
      final transcription = await ApiSTTService.transcribeAndTranslateAudio(
        audioFile,
        _languageRegions[langSelectorController.getInputLang()] ?? "es-ES",
        _languageRegions[langSelectorController.getOutputLang()] ?? "en-US"
      );
      resultText = transcription;

      if (id > _lastSTTId) {
        isTranscribing = false;
        _lastSTTId = id;
      }
    } catch (e) {
      debugPrint("❌ Error en transcribeAndTranslate: $e");
      resultText = 'Error en transcripción o traducción';
      isTranscribing = false;
    }

    return resultText;
  }
}
