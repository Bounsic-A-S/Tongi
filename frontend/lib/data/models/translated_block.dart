import 'dart:math';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// This class is for a block of detected text after being translated 
class TranslatedBlock {
  final String originalText;
  final String translatedText;
  final Rect boundingBox;
  final List<Point<int>> cornerPoints;
  final List<TextLine> lines;

  TranslatedBlock({
    required this.originalText,
    required this.translatedText,
    required this.boundingBox,
    required this.cornerPoints,
    required this.lines,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslatedBlock &&
          runtimeType == other.runtimeType &&
          originalText == other.originalText &&
          translatedText == other.translatedText;

  @override
  int get hashCode => originalText.hashCode ^ translatedText.hashCode;

  get text => null;
}