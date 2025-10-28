import 'package:flutter/rendering.dart';
import 'package:frontend/logic/controllers/lang_selector_controller.dart';
import 'package:frontend/logic/services/text/text_translation.dart';
import 'package:frontend/logic/services/text/local_translation_service.dart';

class TextTranslationController {
  LangSelectorController langSelectorController = LangSelectorController();
  int _lastTranslationId = 0;
  bool isTranslating = false;

  int getLastId() => _lastTranslationId;
  resetId() => _lastTranslationId = 0;

  Future<String> translateText(String text, {int id = 0}) async {
    isTranslating = true;
    String translatedText;
    // check network status
    // use offline translation

    // use azure translation
    try {
      // await Future.delayed(const Duration(milliseconds: 100));
      String translation = "";
      if (langSelectorController.getOutputLang().isNotEmpty) {
        translation = await ApiTranslationService.translateTextAzure(
          text,
          langSelectorController.getInputLang(),
          langSelectorController.getOutputLang(),
        );
      }
      translatedText = translation;
      if (id > _lastTranslationId) {
        isTranslating = false;
        _lastTranslationId = id;
      }
    } catch (e) {
      debugPrint(e.toString());
      translatedText = 'Error en la traducción';
      isTranslating = false;
    }
    return translatedText;
  }
}
