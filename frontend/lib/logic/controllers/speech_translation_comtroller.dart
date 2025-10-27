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
        return "es-ES-AlvaroNeural"; // Español (España)
      case "es-MX":
        return "es-MX-DaliaNeural"; // Español (México)
      case "en-US":
        return "en-US-JennyNeural"; // Inglés (EE. UU.)
      case "en-GB":
        return "en-GB-SoniaNeural"; // Inglés (Reino Unido)
      case "fr-FR":
        return "fr-FR-DeniseNeural"; // Francés (Francia)
      case "de-DE":
        return "de-DE-KatjaNeural"; // Alemán (Alemania)
      case "it-IT":
        return "it-IT-ElsaNeural"; // Italiano (Italia)
      case "pt-PT":
        return "pt-PT-FernandaNeural"; // Portugués (Portugal)
      case "pt-BR":
        return "pt-BR-FranciscaNeural"; // Portugués (Brasil)
      case "zh-CN":
      case "zh-Hans":
        return "zh-CN-XiaoxiaoNeural"; // Chino simplificado (China)
      case "zh-TW":
      case "zh-Hant":
        return "zh-TW-HsiaoChenNeural"; // Chino tradicional (Taiwán)
      case "ja-JP":
        return "ja-JP-NanamiNeural"; // Japonés (Japón)
      case "ko-KR":
        return "ko-KR-SunHiNeural"; // Coreano (Corea del Sur)
      case "ar-SA":
        return "ar-SA-HamedNeural"; // Árabe (Arabia Saudita)
      case "ru-RU":
        return "ru-RU-DariyaNeural"; // Ruso (Rusia)
      case "hi-IN":
        return "hi-IN-SwaraNeural"; // Hindi (India)
      default:
        return "en-US-JennyMultilingualNeural"; // Fallback general
    }
  }

}
