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

      // If offline, use on-device translator; otherwise try online and
      // fallback to device if online fails.
      if (offlineController.isOffline) {
        translatedText = await _translateOnDevice(text);
      } else {
        try {
          translatedText = await _translateOnline(text);
        } catch (e) {
          debugPrint('Online translation failed, falling back to device: $e');
          translatedText = await _translateOnDevice(text);
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

  // Attempt translation using the backend API/Azure service.
  Future<String> _translateOnline(String text) async {
    if (langSelectorController.getOutputLang().isEmpty) return '';
    return await ApiTranslationService.translateTextAzure(
      text,
      langSelectorController.getInputLang(),
      langSelectorController.getOutputLang(),
    );
  }

  // Attempt translation using on-device translator (ML Kit).
  Future<String> _translateOnDevice(String text) async {
    if (langSelectorController.getOutputLang().isEmpty) return '';
    final device = DeviceTranslatorService(
      sourceLanguage: langSelectorController.getInputLang(),
      targetLanguage: langSelectorController.getOutputLang(),
    );
    try {
      return await device.translateText(text);
    } finally {
      await device.close();
    }
  }
}
