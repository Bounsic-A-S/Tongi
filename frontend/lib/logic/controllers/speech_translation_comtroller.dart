import 'package:flutter/rendering.dart';
import 'package:frontend/logic/controllers/lang_selector_controller.dart';
import 'package:frontend/logic/services/audio/speech_service.dart';


class TTSController {
  final LangSelectorController langSelectorController = LangSelectorController();
  int _lastTTSId = 0;
  bool isSynthesizing = false;

  int getLastId() => _lastTTSId;
  void resetId() => _lastTTSId = 0;

  static const Map<String, String> _languageRegions = {
    'es': 'es-ES',
    'en': 'en-US',
    'de': 'de-DE',
    'it': 'it-IT',
    'fr': 'fr-FR',
  };


  Future<String> synthesizeSpeech(
    String text, {
    int id = 0,
  }) async {
    isSynthesizing = true;
    String audioUrl;

    try {
      final inputLang = _languageRegions[langSelectorController.getOutputLang()];
      // 2. Maneja el caso de idioma nulo (ver problema 2)
      if (inputLang == null) {
        throw Exception("Idioma no soportado: ${langSelectorController.getOutputLang()}");
      }
      final selectedVoice = _getDefaultVoiceForLang(inputLang);

      final result = await ApiTTSService.synthesizeSpeech(
        text: text,
        language: inputLang,
        voice: selectedVoice,
      );

      audioUrl = result;

      if (id > _lastTTSId) {
        isSynthesizing = false;
        _lastTTSId = id;
      }
    } catch (e) {
      debugPrint("❌ Error en synthesizeSpeech: $e");
      audioUrl = '';
      isSynthesizing = false;
    }

    return audioUrl;
  }


  String _getDefaultVoiceForLang(String langCode) {
    switch (langCode) {
      case "es-ES":
        return "es-ES-TristanMultilingualNeural";
      case "en-US":
        return "en-US-JennyMultilingualNeural";
      case "fr-FR":
        return "fr-FR-DeniseMultilingualNeural";
      case "pt-BR":
        return "pt-BR-FranciscaMultilingualNeural";
      default:
        return "es-ES-TristanMultilingualNeural";
    }
  }
}
