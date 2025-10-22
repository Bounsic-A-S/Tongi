import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:frontend/logic/controllers/lang_selector_controller.dart';
import 'package:frontend/logic/services/audio/transcription_service.dart';

class STTController {
  final LangSelectorController langSelectorController = LangSelectorController();
  int _lastSTTId = 0;
  bool isTranscribing = false;
  static const Map<String, String> _languageRegions = {
    'es': 'es-ES',
    'en': 'en-US',
    'de': 'de-DE',
    'it': 'it-IT',
    'fr': 'fr-FR',
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
