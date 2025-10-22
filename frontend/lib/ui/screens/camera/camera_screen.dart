import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/logic/utils/permissions.dart';
import 'package:frontend/triggers/camera/camera_translation_painter.dart';
import 'package:frontend/ui/screens/camera/camera_view.dart';
import 'package:frontend/ui/screens/camera/gallery_view.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/logic/services/camera/image_translation_service.dart';

class CameraScreen extends StatefulWidget {
  final VoidCallback toggleBlockView;
  const CameraScreen({super.key, required this.toggleBlockView});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;
  bool _isCamera = true;
  Function(CameraLensDirection direction)? onCameraLensDirectionChanged;

  late ImageTranslationService _translationManager;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _translationManager = ImageTranslationService();
    _initPermission();
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
    switch (isCameraPermitted) {
      case null:
        return Scaffold();
      case false:
        return _buildPermDenied(context);
      case true:
        return _buildDetectorView(context);
    }
  }

  Widget _buildDetectorView(BuildContext context) {
    return PopScope(
      canPop: _isCamera,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!_isCamera) {
          _onDetectorViewModeChanged();
          return;
        }
      },
      child: _isCamera
          ? CameraView(
              customPaint: _customPaint,
              onImage: _processImage,
              onDetectorViewModeChanged: _onDetectorViewModeChanged,
              initialCameraLensDirection: CameraLensDirection.back,
              onCameraLensDirectionChanged: onCameraLensDirectionChanged,
            )
          : GalleryView(
              title: "",
              text: _text,
              onImage: _processImage,
              onDetectorViewModeChanged: _onDetectorViewModeChanged,
            ),
    );
  }

  void _onDetectorViewModeChanged() {
    _isCamera = !_isCamera;
    widget.toggleBlockView();
    setState(() {});
  }

  _updatePermission() async {
    await checkCameraPermission();
    if (mounted) {
      setState(() {});
    }
  }

  _initPermission() async {
    await askCameraPermission();
    if (mounted) setState(() {});
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
        // _text =
        //     'Original: ${result.originalText}\n\nTraducido: ${result.translatedText}';
        _text = result.translatedText;
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
      _text = 'Error: $e';
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
