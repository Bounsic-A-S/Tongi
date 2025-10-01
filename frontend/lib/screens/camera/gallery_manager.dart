import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryManager {
  Future<void> saveImageToGallery(
    Uint8List imageBytes, {
    bool isOverlay = false,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final String title = isOverlay 
          ? 'translated_photo_${DateTime.now().millisecondsSinceEpoch}.png'
          : 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final AssetEntity? asset = await PhotoManager.editor.saveImage(
        imageBytes,
        title: title, filename: '',
      );

      if (asset != null) {
        onSuccess('Imagen guardada en galería');
      } else {
        throw Exception('No se pudo guardar la imagen en la galería');
      }
    } catch (e) {
      // Fallback: guardar en directorio de la app
      await _saveToAppDirectory(imageBytes, isOverlay: isOverlay);
      onError('Imagen guardada en carpeta de la aplicación: $e');
    }
  }

  Future<AssetEntity?> _saveToSystemGallery(
    Uint8List imageBytes, {
    required bool isOverlay,
  }) async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    if (!state.hasAccess) {
      throw Exception('Permisos de galería denegados');
    }

    final fileName = isOverlay
        ? 'translated_photo_${DateTime.now().millisecondsSinceEpoch}.png'
        : 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

    return await PhotoManager.editor.saveImage(
      imageBytes,
      title: fileName, filename: '',
    );
  }

  Future<void> _saveToAppDirectory(
    Uint8List imageBytes, {
    required bool isOverlay,
  }) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = isOverlay
        ? 'translated_photo_${DateTime.now().millisecondsSinceEpoch}.png'
        : 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = '${appDir.path}/$fileName';

    final File imageFile = File(filePath);
    await imageFile.writeAsBytes(imageBytes);
    
    print('Imagen guardada en directorio de la app: $filePath');
  }
}