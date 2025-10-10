import 'translated_block.dart';

// This class is for All text detection result on an image
class TextDetectionResult {
  final String originalText;
  final String translatedText;
  final List<TranslatedBlock> blocks;

  TextDetectionResult({
    required this.originalText,
    required this.translatedText,
    required this.blocks,
  });

  bool get hasTranslation => translatedText.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextDetectionResult &&
          runtimeType == other.runtimeType &&
          originalText == other.originalText &&
          translatedText == other.translatedText &&
          blocks.length == other.blocks.length;

  @override
  int get hashCode =>
      originalText.hashCode ^ translatedText.hashCode ^ blocks.length.hashCode;
}