import 'package:flutter/services.dart';

/// A class that translates on device the given input text.
class DeviceTranslatorService {
  static const MethodChannel _channel = MethodChannel(
    'google_mlkit_on_device_translator',
  );

  /// The source language of the input.
  final String sourceLanguage;

  /// The target language to translate the input into.
  final String targetLanguage;

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Constructor to create an instance of [DeviceTranslatorService].
  DeviceTranslatorService({
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  /// Translates the given [text] from the source language into the target language.
  Future<String> translateText(String text) async {
    if (sourceLanguage.isEmpty || targetLanguage.isEmpty) {
      throw Exception("Source or target language not set");
    }

    final result = await _channel.invokeMethod(
      'nlp#startLanguageTranslator',
      <String, dynamic>{
        'id': id,
        'text': text,
        'source': sourceLanguage,
        'target': targetLanguage,
      },
    );

    return result.toString();
  }

  /// Closes the translator and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('nlp#closeLanguageTranslator', {'id': id});
}
