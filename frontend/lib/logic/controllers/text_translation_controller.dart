import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:frontend/logic/controllers/lang_selector_controller.dart';
import 'package:frontend/logic/controllers/offline_check_controller.dart';
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
    // Determine connectivity via OfflineCheckController. The controller
    // performs an async initial check in its constructor, so wait until
    // its initial loading completes before reading `isOffline`.
    final offlineController = OfflineCheckController();
    try {
      if (offlineController.loading) {
        final completer = Completer<void>();
        void listener() {
          if (!offlineController.loading) {
            completer.complete();
          }
        }

        offlineController.addListener(listener);
        // Wait for initial load to finish (should be fast).
        await completer.future.timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            // If timeout, proceed with downstream (assume online) to avoid blocking.
          },
        );
        offlineController.removeListener(listener);
      }

      // If offline, use on-device translator
      if (offlineController.isOffline) {
        if (langSelectorController.getOutputLang().isNotEmpty) {
          final device = DeviceTranslatorService(
            sourceLanguage: langSelectorController.getInputLang(),
            targetLanguage: langSelectorController.getOutputLang(),
          );
          try {
            final deviceTranslation = await device.translateText(text);
            translatedText = deviceTranslation;
          } finally {
            // release native translator resources
            await device.close();
          }
        } else {
          translatedText = '';
        }
      } else {
        // Online: use API/Azure translation
        try {
          String translation = "";
          if (langSelectorController.getOutputLang().isNotEmpty) {
            translation = await ApiTranslationService.translateTextAzure(
              text,
              langSelectorController.getInputLang(),
              langSelectorController.getOutputLang(),
            );
          }
          translatedText = translation;
        } catch (e) {
          // If online translation fails, fall back to on-device translation
          debugPrint('Online translation failed: $e');
          if (langSelectorController.getOutputLang().isNotEmpty) {
            final device = DeviceTranslatorService(
              sourceLanguage: langSelectorController.getInputLang(),
              targetLanguage: langSelectorController.getOutputLang(),
            );
            try {
              translatedText = await device.translateText(text);
            } finally {
              await device.close();
            }
          } else {
            translatedText = '';
          }
        }
      }

      if (id > _lastTranslationId) {
        _lastTranslationId = id;
      }
    } catch (e) {
      debugPrint(e.toString());
      translatedText = 'Error en la traducción';
    } finally {
      // ensure flags are updated and resources cleaned
      isTranslating = false;
      try {
        offlineController.dispose();
      } catch (_) {}
    }

    return translatedText;
  }
}
