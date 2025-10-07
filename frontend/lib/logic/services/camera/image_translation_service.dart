import 'package:frontend/logic/controllers/lang_selector_controller.dart';
import 'package:frontend/logic/models/text_detection_result.dart';
import 'package:frontend/logic/models/translated_block.dart';
import 'package:frontend/logic/services/camera/ocr/text_block_merger.dart';
import 'package:frontend/logic/services/translation_service.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ImageTranslationService {
  late final TextRecognizer _recognitionService;
  final TranslationService _translationService;
  final TextBlockMerger _textBlockMerger;

  ImageTranslationService({
    double horizontalMergeThreshold = 50.0,
    double verticalMergeThreshold = 30.0,
  }) : _recognitionService = TextRecognizer(),
       _translationService = TranslationService(),
       _textBlockMerger = TextBlockMerger(
         horizontalMergeThreshold: horizontalMergeThreshold,
         verticalMergeThreshold: verticalMergeThreshold,
       );

  Future<TextDetectionResult> processImageForTranslation(
    InputImage inputImage,
  ) async {
    try {
      // 1. Reconocer texto
      final recognizedText = await _recognitionService.processImage(inputImage);

      if (recognizedText.blocks.isEmpty) {
        return TextDetectionResult(
          originalText: '',
          translatedText: '',
          blocks: [],
        );
      }

      final mergedBlocks = _textBlockMerger.mergeNearbyBlocks(
        recognizedText.blocks,
      );

      print('Bloques originales: ${recognizedText.blocks.length}');
      print('Bloques después de unir: ${mergedBlocks.length}');

      final List<TranslatedBlock> translatedBlocks = [];
      String fullOriginalText = '';
      String fullTranslatedText = '';

      LangSelectorController langSelectorController = LangSelectorController();

      for (final block in mergedBlocks) {
        final blockText = block.text;
        final translatedBlockText = await _translationService.translateText(
          blockText,
          from: langSelectorController.getInputLang(),
          to: langSelectorController.getOutputLang(),
        );

        translatedBlocks.add(
          TranslatedBlock(
            originalText: blockText,
            translatedText: translatedBlockText,
            boundingBox: block.boundingBox,
            cornerPoints: block.cornerPoints,
            lines: block.lines,
          ),
        );

        fullOriginalText += '$blockText ';
        fullTranslatedText += '$translatedBlockText ';
      }

      // Limpiar textos finales
      fullOriginalText = fullOriginalText.trim();
      fullTranslatedText = fullTranslatedText.trim();

      return TextDetectionResult(
        originalText: fullOriginalText,
        translatedText: fullTranslatedText,
        blocks: translatedBlocks,
      );
    } catch (e) {
      print('Error en processImageForTranslation: $e');
      return TextDetectionResult(
        originalText: '',
        translatedText: 'Error en traducción',
        blocks: [],
      );
    }
  }

  // Método para actualizar parámetros de agrupación
  void updateMergeParameters({
    double? horizontalMergeThreshold,
    double? verticalMergeThreshold,
    double? maxAreaRatio,
  }) {
    _textBlockMerger.horizontalMergeThreshold =
        horizontalMergeThreshold ?? _textBlockMerger.horizontalMergeThreshold;
    _textBlockMerger.verticalMergeThreshold =
        verticalMergeThreshold ?? _textBlockMerger.verticalMergeThreshold;
    _textBlockMerger.maxAreaRatio =
        maxAreaRatio ?? _textBlockMerger.maxAreaRatio;
  }

  void updateRecognitionScript(TextRecognitionScript script) {
    _recognitionService.close();
    _recognitionService = TextRecognizer(script: script);
  }

  void dispose() {
    _recognitionService.close();
  }
}
