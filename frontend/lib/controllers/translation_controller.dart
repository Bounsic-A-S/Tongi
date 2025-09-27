import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_languages.dart';
import 'package:frontend/services/text_translation.dart';

class TranslationController extends ChangeNotifier {
  // Language selection state
  String _sourceLanguageCode = availableLanguages[0].code;
  String _targetLanguageCode = availableLanguages[1].code;

  // Text translation state
  String _inputText = '';
  String _translatedText = '';
  bool _isTranslating = false;
  String? _errorMessage;

  // Getters
  String get sourceLanguageCode => _sourceLanguageCode;
  String get targetLanguageCode => _targetLanguageCode;
  String get inputText => _inputText;
  String get translatedText => _translatedText;
  bool get isTranslating => _isTranslating;
  String? get errorMessage => _errorMessage;

  // Get language labels for display
  String get sourceLanguageLabel {
    return availableLanguages
        .firstWhere((lang) => lang.code == _sourceLanguageCode)
        .label;
  }

  String get targetLanguageLabel {
    return availableLanguages
        .firstWhere((lang) => lang.code == _targetLanguageCode)
        .label;
  }

  // Language selection methods
  void setSourceLanguage(String languageCode) {
    if (_sourceLanguageCode != languageCode) {
      _sourceLanguageCode = languageCode;
      _clearError();
      notifyListeners();

      // Re-translate if there's input text
      if (_inputText.isNotEmpty) {
        _performTranslation();
      }
    }
  }

  void setTargetLanguage(String languageCode) {
    if (_targetLanguageCode != languageCode) {
      _targetLanguageCode = languageCode;
      _clearError();
      notifyListeners();

      // Re-translate if there's input text
      if (_inputText.isNotEmpty) {
        _performTranslation();
      }
    }
  }

  void swapLanguages() {
    final temp = _sourceLanguageCode;
    _sourceLanguageCode = _targetLanguageCode;
    _targetLanguageCode = temp;

    _inputText = _translatedText;
    _translatedText = '';

    _clearError();
    notifyListeners();

    // Re-translate if there's input text
    if (_inputText.isNotEmpty) {
      _performTranslation();
    }
  }

  // Text input methods
  void setInputText(String text) {
    if (_inputText != text) {
      _inputText = text;
      _clearError();

      if (text.isEmpty) {
        _translatedText = '';
        _isTranslating = false;
      } else {
        _performTranslation();
      }

      notifyListeners();
    }
  }

  void clearText() {
    _inputText = '';
    _translatedText = '';
    _isTranslating = false;
    _clearError();
    notifyListeners();
  }

  // Translation methods

  Future<void> _performTranslation() async {
    if (_inputText.isEmpty) return;

    _isTranslating = true;
    _clearError();
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final translation = await ApiTranslationService.translateText(
        _inputText,
        _sourceLanguageCode,
        _targetLanguageCode,
      );
      _translatedText = translation;
      _isTranslating = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _translatedText = 'Error en la traducción';
      _isTranslating = false;
      notifyListeners();
    }
  }

  // Utility methods
  void _clearError() {
    _errorMessage = null;
  }

  // Get available languages excluding the currently selected one
  List<Language> getAvailableSourceLanguages() {
    return availableLanguages
        .where((lang) => lang.code != _targetLanguageCode)
        .toList();
  }

  List<Language> getAvailableTargetLanguages() {
    return availableLanguages
        .where((lang) => lang.code != _sourceLanguageCode)
        .toList();
  }
}
