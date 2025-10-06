import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import 'package:frontend/logic/utils/coordinates.dart';
import 'package:frontend/logic/models/text_detection_result.dart';
import 'package:frontend/logic/models/translated_block.dart';

class CameraTranslationPainter extends CustomPainter {
  CameraTranslationPainter(
    this.detectionResult,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final TextDetectionResult detectionResult;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    if (detectionResult.blocks.isEmpty) return;

    final Paint boundingBoxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.transparent;

    final Paint textBackgroundPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255);

    for (final translatedBlock in detectionResult.blocks) {
      if (translatedBlock.translatedText.isEmpty) continue;

      // Dibujar bounding box del bloque (opcional)
      final List<Offset> cornerPoints = _calculateCornerPoints(
        translatedBlock,
        size,
      );
      canvas.drawPoints(PointMode.polygon, cornerPoints, boundingBoxPaint);

      // Dibujar texto traducido ajustado al bloque
      _drawAdjustedTranslatedText(
        canvas,
        translatedBlock,
        size,
        textBackgroundPaint,
      );
    }
  }

  void _drawAdjustedTranslatedText(
    Canvas canvas,
    TranslatedBlock translatedBlock,
    Size size,
    Paint backgroundPaint,
  ) {
    final block = translatedBlock;
    final translatedText = block.translatedText;

    // Calcular posición y tamaño del bloque en la pantalla
    final left = translateX(
      block.boundingBox.left,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    final top = translateY(
      block.boundingBox.top,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    final right = translateX(
      block.boundingBox.right,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    final bottom = translateY(
      block.boundingBox.bottom,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );

    final blockWidth = (right - left).abs();
    final blockHeight = (bottom - top).abs();

    // Si el bloque es muy pequeño, no dibujar texto
    if (blockWidth < 10 || blockHeight < 10) return;

    // Calcular el tamaño de fuente óptimo para que quepa el texto
    final optimalFontSize = _calculateOptimalFontSize(
      translatedText,
      blockWidth,
      blockHeight,
    );

    // Dividir el texto en líneas que quepan en el ancho del bloque
    final textLines = _splitTextToFitWidth(
      translatedText,
      blockWidth,
      optimalFontSize,
    );

    // Calcular la altura total del texto
    final lineHeight = optimalFontSize * 1.2;
    final totalTextHeight = lineHeight * textLines.length;

    // Si el texto no cabe en la altura, reducir más el font size
    final adjustedFontSize = totalTextHeight > blockHeight
        ? optimalFontSize * (blockHeight / totalTextHeight)
        : optimalFontSize;

    final adjustedLineHeight = adjustedFontSize * 1.2;

    // Calcular posición vertical centrada
    final startY =
        top + (blockHeight - (adjustedLineHeight * textLines.length)) / 2;

    // Dibujar cada línea de texto
    for (int i = 0; i < textLines.length; i++) {
      final line = textLines[i];

      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: adjustedFontSize,
          textDirection: TextDirection.ltr,
          fontWeight: FontWeight.w600,
        ),
      );

      builder.pushStyle(
        ui.TextStyle(
          color: const Color.fromARGB(255, 0, 0, 0),
          background: backgroundPaint,
        ),
      );
      builder.addText(line);
      builder.pop();

      final paragraph = builder.build()
        ..layout(ParagraphConstraints(width: blockWidth));

      final yPosition = startY + (i * adjustedLineHeight);

      // Asegurar que no se salga de los límites del bloque
      if (yPosition + adjustedLineHeight <= bottom && yPosition >= top) {
        canvas.drawParagraph(paragraph, Offset(left, yPosition));
      }
    }
  }

  /// Calcula el tamaño de fuente óptimo para que el texto quepa en el bloque
  double _calculateOptimalFontSize(
    String text,
    double maxWidth,
    double maxHeight,
  ) {
    const double minFontSize = 8.0;
    const double maxFontSize = 24.0;

    // Probamos diferentes tamaños de fuente
    for (
      double fontSize = maxFontSize;
      fontSize >= minFontSize;
      fontSize -= 1.0
    ) {
      final textLines = _splitTextToFitWidth(text, maxWidth, fontSize);
      final lineHeight = fontSize * 1.2;
      final totalHeight = lineHeight * textLines.length;

      if (totalHeight <= maxHeight) {
        return fontSize;
      }
    }

    return minFontSize;
  }

  /// Divide el texto en líneas que quepan en el ancho disponible (VERSIÓN ROBUSTA)
  List<String> _splitTextToFitWidth(
    String text,
    double maxWidth,
    double fontSize,
  ) {
    if (text.isEmpty) return [];

    // Si el ancho es muy pequeño, dividir por caracteres directamente
    if (maxWidth < fontSize * 5) {
      return _splitTextByCharacters(text, maxWidth, fontSize);
    }

    final words = text.split(' ');
    final lines = <String>[];
    String currentLine = '';

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final potentialLine = currentLine.isEmpty ? word : '$currentLine $word';

      // Medir el ancho del texto
      final textPainter = TextPainter(
        text: TextSpan(
          text: potentialLine,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(minWidth: 0, maxWidth: double.infinity);
      final textWidth = textPainter.width;

      if (textWidth <= maxWidth) {
        currentLine = potentialLine;
      } else {
        // Si es la primera palabra de la línea y no cabe, dividir la palabra
        if (currentLine.isEmpty) {
          final dividedWord = _splitLongWord(word, maxWidth, fontSize);
          lines.addAll(dividedWord.take(dividedWord.length - 1));
          currentLine = dividedWord.last;
        } else {
          lines.add(currentLine);
          currentLine = word;
        }
      }

      // Agregar la última línea
      if (i == words.length - 1 && currentLine.isNotEmpty) {
        lines.add(currentLine);
      }
    }

    return lines;
  }

  /// Divide palabras muy largas que no caben en una línea
  List<String> _splitLongWord(String word, double maxWidth, double fontSize) {
    if (word.length <= 8) return [word];

    final parts = <String>[];
    int start = 0;

    while (start < word.length) {
      int end = start + 8;
      if (end > word.length) end = word.length;

      final part = word.substring(start, end);
      parts.add(part);
      start = end;
    }

    return parts;
  }

  /// Divide el texto por caracteres cuando las palabras son muy largas
  List<String> _splitTextByCharacters(
    String text,
    double maxWidth,
    double fontSize,
  ) {
    final lines = <String>[];
    int startIndex = 0;

    // Calcular cuántos caracteres caben aproximadamente
    final avgCharWidth = fontSize * 0.6;
    final maxCharsPerLine = (maxWidth / avgCharWidth).floor();
    final safeMaxChars = maxCharsPerLine > 3 ? maxCharsPerLine : 8;

    while (startIndex < text.length) {
      int endIndex = startIndex + safeMaxChars;
      if (endIndex > text.length) {
        endIndex = text.length;
      }

      String line = text.substring(startIndex, endIndex).trim();
      if (line.isNotEmpty) {
        lines.add(line);
      }

      startIndex = endIndex;
    }

    return lines;
  }

  List<Offset> _calculateCornerPoints(
    TranslatedBlock translatedBlock,
    Size size,
  ) {
    final List<Offset> cornerPoints = <Offset>[];

    for (final point in translatedBlock.cornerPoints) {
      double x = translateX(
        point.x.toDouble(),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      double y = translateY(
        point.y.toDouble(),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      // Aplicar correcciones para Android (mantener lógica existente)
      if (Platform.isAndroid) {
        switch (cameraLensDirection) {
          case CameraLensDirection.front:
            switch (rotation) {
              case InputImageRotation.rotation0deg:
              case InputImageRotation.rotation90deg:
                break;
              case InputImageRotation.rotation180deg:
                x = size.width - x;
                y = size.height - y;
                break;
              case InputImageRotation.rotation270deg:
                x = translateX(
                  point.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                );
                y =
                    size.height -
                    translateY(
                      point.x.toDouble(),
                      size,
                      imageSize,
                      rotation,
                      cameraLensDirection,
                    );
                break;
            }
            break;
          case CameraLensDirection.back:
            switch (rotation) {
              case InputImageRotation.rotation0deg:
              case InputImageRotation.rotation270deg:
                break;
              case InputImageRotation.rotation180deg:
                x = size.width - x;
                y = size.height - y;
                break;
              case InputImageRotation.rotation90deg:
                x =
                    size.width -
                    translateX(
                      point.y.toDouble(),
                      size,
                      imageSize,
                      rotation,
                      cameraLensDirection,
                    );
                y = translateY(
                  point.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                );
                break;
            }
            break;
          case CameraLensDirection.external:
            break;
        }
      }

      cornerPoints.add(Offset(x, y));
    }

    cornerPoints.add(cornerPoints.first);
    return cornerPoints;
  }

  @override
  bool shouldRepaint(CameraTranslationPainter oldDelegate) {
    return oldDelegate.detectionResult != detectionResult;
  }
}
