import 'dart:math';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextBlockMerger {
  // Parámetros configurables para la agrupación
  double horizontalMergeThreshold; // Distancia horizontal máxima para unir
  double verticalMergeThreshold; // Distancia vertical máxima para unir
  double maxAreaRatio; // Ratio máximo de área para considerar cercanía

  TextBlockMerger({
    this.horizontalMergeThreshold = 50.0,
    this.verticalMergeThreshold = 30.0,
    this.maxAreaRatio = 5.0,
  });

  // Agrupa y une bloques de texto que están cercanos
  List<TextBlock> mergeNearbyBlocks(List<TextBlock> blocks) {
    if (blocks.length <= 1) return blocks;

    final List<TextBlock> mergedBlocks = [];
    final List<bool> merged = List.filled(blocks.length, false);

    for (int i = 0; i < blocks.length; i++) {
      if (merged[i]) continue;

      TextBlock currentBlock = blocks[i];
            
      List<TextBlock> blocksToMerge = [currentBlock];

      // Buscar bloques cercanos al actual
      for (int j = i + 1; j < blocks.length; j++) {
        if (merged[j]) continue;

        final TextBlock otherBlock = blocks[j];

        if (_shouldMergeBlocks(currentBlock, otherBlock)) {
          blocksToMerge.add(otherBlock);
          merged[j] = true;
          print('✅ Uniendo bloque $j con bloque $i');
        }
      }

      if (blocksToMerge.length == 1) {
        // No hay bloques para unir, mantener el original
        mergedBlocks.add(currentBlock);
        print('➡️ Manteniendo bloque individual: "${currentBlock.text}"');
      } else {
        // Unir los bloques cercanos
        final TextBlock mergedBlock = _mergeTextBlocks(blocksToMerge);
        mergedBlocks.add(mergedBlock);
        print('🔄 Bloque fusionado creado: "${mergedBlock.text}"');
      }

      merged[i] = true;
    }

    print('🎯 Resumen: ${blocks.length} → ${mergedBlocks.length} bloques');
    return mergedBlocks;
  }

  /// Determina si dos bloques deben unirse basado en distancia y características
  bool _shouldMergeBlocks(TextBlock block1, TextBlock block2) {
    final rect1 = block1.boundingBox;
    final rect2 = block2.boundingBox;

    // Verificar si las áreas son similares (evitar unir títulos con texto pequeño)
    final area1 = rect1.width * rect1.height;
    final area2 = rect2.width * rect2.height;
    final areaRatio = area1 > area2 ? area1 / area2 : area2 / area1;

    if (areaRatio > maxAreaRatio) {
      return false; // Las áreas son muy diferentes, probablemente no relacionados
    }

    // Calcular distancias entre bloques
    final horizontalDistance = _calculateHorizontalDistance(rect1, rect2);
    final verticalDistance = _calculateVerticalDistance(rect1, rect2);

    // Verificar si están en la misma línea (alineados horizontalmente)
    final bool inSameLine = _areInSameLine(rect1, rect2);

    if (inSameLine) {
      // Para texto en la misma línea, usar umbral horizontal más permisivo
      return horizontalDistance <= horizontalMergeThreshold;
    } else {
      // Para texto en diferentes líneas, verificar proximidad vertical y horizontal
      return horizontalDistance <= horizontalMergeThreshold * 0.7 &&
          verticalDistance <= verticalMergeThreshold;
    }
  }

  /// Calcula la distancia horizontal entre dos rectángulos
  double _calculateHorizontalDistance(Rect rect1, Rect rect2) {
    if (rect1.right < rect2.left) {
      return rect2.left - rect1.right; // rect1 está a la izquierda de rect2
    } else if (rect2.right < rect1.left) {
      return rect1.left - rect2.right; // rect2 está a la izquierda de rect1
    } else {
      return 0.0; // Se superponen horizontalmente
    }
  }

  /// Calcula la distancia vertical entre dos rectángulos
  double _calculateVerticalDistance(Rect rect1, Rect rect2) {
    if (rect1.bottom < rect2.top) {
      return rect2.top - rect1.bottom; // rect1 está arriba de rect2
    } else if (rect2.bottom < rect1.top) {
      return rect1.top - rect2.bottom; // rect2 está arriba de rect1
    } else {
      return 0.0; // Se superponen verticalmente
    }
  }

  /// Verifica si dos rectángulos están aproximadamente en la misma línea
  bool _areInSameLine(Rect rect1, Rect rect2) {
    final centerY1 = rect1.center.dy;
    final centerY2 = rect2.center.dy;
    final heightTolerance = (rect1.height + rect2.height) / 4;

    return (centerY1 - centerY2).abs() <= heightTolerance;
  }

  /// Une múltiples bloques de texto en uno solo
  TextBlock _mergeTextBlocks(List<TextBlock> blocks) {
    if (blocks.isEmpty) throw ArgumentError('Blocks cannot be empty');
    if (blocks.length == 1) return blocks.first;

    // Calcular el rectángulo que contiene todos los bloques
    Rect mergedRect = blocks.first.boundingBox;
    String mergedText = blocks.first.text;
    List<TextLine> mergedLines = [...blocks.first.lines];

    for (int i = 1; i < blocks.length; i++) {
      final block = blocks[i];
      mergedRect = mergedRect.expandToInclude(block.boundingBox);
      mergedText += ' ${block.text}'; // Unir texto con espacio
      mergedLines.addAll(block.lines);
    }

    // Calcular puntos de esquina del rectángulo fusionado
    final List<Point<int>> mergedCorners = [
      Point(mergedRect.left.toInt(), mergedRect.top.toInt()),
      Point(mergedRect.right.toInt(), mergedRect.top.toInt()),
      Point(mergedRect.right.toInt(), mergedRect.bottom.toInt()),
      Point(mergedRect.left.toInt(), mergedRect.bottom.toInt()),
    ];

    // ✅ CORRECCIÓN: Usar _createMergedTextBlock en lugar de la lógica anterior
    return _createMergedTextBlock(
      mergedText,
      mergedRect,
      mergedCorners,
      blocks,
    );
  }

  /// ✅ CORRECCIÓN: Esta función SÍ se usa ahora
  TextBlock _createMergedTextBlock(
    String text,
    Rect boundingBox,
    List<Point<int>> cornerPoints,
    List<TextBlock> originalBlocks,
  ) {
    // Obtener los lenguajes reconocidos del primer bloque
    final recognizedLanguages = originalBlocks.first.recognizedLanguages;

    // Combinar todas las líneas de texto
    final List<TextLine> allLines = [];
    for (final block in originalBlocks) {
      allLines.addAll(block.lines);
    }

    // Crear y retornar el TextBlock fusionado
    return TextBlock(
      text: text,
      boundingBox: boundingBox,
      cornerPoints: cornerPoints,
      recognizedLanguages: recognizedLanguages,
      lines: allLines,
    );
  }
}

/// Extensión para Rect para expandir y unir rectángulos
extension RectExtensions on Rect {
  Rect expandToInclude(Rect other) {
    final left = this.left < other.left ? this.left : other.left;
    final top = this.top < other.top ? this.top : other.top;
    final right = this.right > other.right ? this.right : other.right;
    final bottom = this.bottom > other.bottom ? this.bottom : other.bottom;

    return Rect.fromLTRB(left, top, right, bottom);
  }
}