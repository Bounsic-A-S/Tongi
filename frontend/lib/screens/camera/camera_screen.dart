import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/data/utils/permissions.dart';
import 'package:frontend/screens/camera/text_detector_painter.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

import 'detector_view.dart';
import 'package:frontend/data/services/camera/image_translation_service.dart';

class CameraScreen extends StatefulWidget {
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  bool? camera;

  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  late ImageTranslationService _translationManager;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _translationManager = ImageTranslationService();
    askCameraPermission();
    _updatePermission();
  }

  @override
  void dispose() async {
    _canProcess = false;
    _translationManager.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (camera) {
      case null:
        return Scaffold();
      case false:
        return _buildPermDenied(context);
      case true:
        return DetectorView(
          title: 'Text Detector',
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        );
    }
  }

  _updatePermission() async {
    await checkCameraPermission();
    camera = isCameraPermitted;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;

    _isBusy = true;
    setState(() {
      _text = '';
    });

    try {
      final result = await _translationManager.processImageForTranslation(
        inputImage,
      );

      print('📋 Bloques enviados al painter: ${result.blocks.length}');
      for (int i = 0; i < result.blocks.length; i++) {
        final block = result.blocks[i];
        print(
          '   Bloque $i: "${block.originalText}" -> "${block.translatedText}" - Pos: ${block.boundingBox}',
        );
      }

      setState(() {
        _text =
            'Original: ${result.originalText}\n\nTraducido: ${result.translatedText}';
      });

      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = CameraTranslationPainter(
          result,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
      } else {
        _customPaint = null;
      }
    } catch (e) {
      print('Error en _processImage: $e');
      setState(() {
        _text = 'Error: $e';
      });
    } finally {
      _isBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildPermDenied(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Acceso a cámara denegado."),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                openAppSettings();
              },
              child: Text("Abrir configuración"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updatePermission();
    }
  }
}
