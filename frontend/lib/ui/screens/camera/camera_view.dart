import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/camera/camera_lang_selector.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../logic/services/camera/managers/camera_manager.dart';
import '../../../logic/services/camera/managers/gallery_manager.dart';
import '../../../logic/services/camera/overlay_capturer.dart';

class CameraView extends StatefulWidget {
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  const CameraView({
    super.key,
    required this.customPaint,
    required this.onImage,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
    this.initialCameraLensDirection = CameraLensDirection.back,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraManager _cameraManager;
  late GalleryManager _galleryManager;
  late OverlayCapturer _overlayCapturer;

  // Estado de UI
  bool _changingCameraLens = false;
  bool _showExposureControl = false;
  bool _isCapturing = false;
  double _baseScale = 1.0;
  double _currentScale = 1.0;

  final GlobalKey _cameraPreviewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeManagers();
  }

  void _initializeManagers() {
    _cameraManager = CameraManager(
      initialCameraLensDirection: widget.initialCameraLensDirection,
      onImage: widget.onImage,
      onCameraFeedReady: widget.onCameraFeedReady,
      onCameraLensDirectionChanged: widget.onCameraLensDirectionChanged,
    );

    _galleryManager = GalleryManager();
    _overlayCapturer = OverlayCapturer(_cameraPreviewKey);
  }

  @override
  void dispose() {
    _cameraManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildCameraView());
  }

  Widget _buildCameraView() {
    final controller = _cameraManager.controller;

    if (controller == null || !controller.value.isInitialized) {
      return _buildLoadingView();
    }

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Vista previa de cámara con gestos
          _buildCameraPreview(controller),

          // Controles de UI
          // _backButton(),
          _languageSelector(),
          _detectionViewModeToggle(),
          _switchLiveCameraToggle(),
          _captureButton(),
          _exposureButton(),
          _exposureControl(),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Inicializando cámara...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(CameraController controller) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: RepaintBoundary(
        key: _cameraPreviewKey,
        child: Center(
          child: _changingCameraLens
              ? Center(
                  child: Text(
                    'Cambiando cámara...',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : CameraPreview(controller, child: widget.customPaint),
        ),
      ),
    );
  }

  // ========== GESTOS DE ZOOM ==========
  void _onScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    _currentScale = (_baseScale * details.scale).clamp(1.0, 5.0);
    final minZoom = _cameraManager.minZoomLevel;
    final maxZoom = _cameraManager.maxZoomLevel;

    final newZoom = minZoom + (_currentScale - 1.0) * (maxZoom - minZoom) / 4.0;
    _cameraManager.setZoomLevel(newZoom.clamp(minZoom, maxZoom));
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _baseScale = _currentScale;
  }

  // ========== CONTROLES DE UI ==========
  // Widget _backButton() => Positioned(
  //   top: 40,
  //   left: 8,
  //   child: _buildIconButton(
  //     icon: Icons.arrow_back_ios_outlined,
  //     onPressed: () => Navigator.of(context).pop(),
  //   ),
  // );

  Widget _languageSelector() => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color.fromARGB(146, 0, 0, 0), Colors.transparent],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: CameraLangSelector(),
        ),
      ),
    ),
  );

  Widget _detectionViewModeToggle() => Positioned(
    bottom: 8,
    left: 8,
    child: _buildIconButton(
      icon: Icons.photo_library_outlined,
      onPressed: widget.onDetectorViewModeChanged,
    ),
  );

  Widget _switchLiveCameraToggle() => Positioned(
    bottom: 8,
    right: 8,
    child: _buildIconButton(
      icon: Platform.isIOS
          ? Icons.flip_camera_ios_outlined
          : Icons.flip_camera_android_outlined,
      onPressed: _switchCamera,
    ),
  );

  Widget _captureButton() => Positioned(
    bottom: 70,
    left: 0,
    right: 0,
    child: Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          heroTag: Object(),
          onPressed: _isCapturing ? null : _captureImageWithOverlay,
          backgroundColor: _isCapturing ? Colors.grey : Colors.white,
          child: _isCapturing
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                )
              : Icon(Icons.camera, size: 30, color: Colors.black),
        ),
      ),
    ),
  );

  Widget _exposureButton() => Positioned(
    bottom: 70,
    right: 8,
    child: _buildIconButton(
      icon: _showExposureControl
          ? Icons.brightness_medium
          : Icons.brightness_medium_outlined,
      onPressed: _toggleExposureControl,
    ),
  );

  Widget _exposureControl() => _showExposureControl
      ? Positioned(bottom: 90, right: 8, child: _buildExposureSlider())
      : const SizedBox.shrink();

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 50.0,
      width: 50.0,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.black54,
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildExposureSlider() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 250),
      child: Column(
        children: [
          Container(
            width: 55,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  _cameraManager.currentExposureOffset.toStringAsFixed(1),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: RotatedBox(
                quarterTurns: 3,
                child: SizedBox(
                  height: 30,
                  width: 150,
                  child: Slider(
                    value: _cameraManager.currentExposureOffset,
                    min: _cameraManager.minAvailableExposureOffset,
                    max: _cameraManager.maxAvailableExposureOffset,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: _onExposureChanged,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onExposureChanged(double value) {
    _cameraManager.setExposureOffset(value);
    setState(() {});
  }

  // ========== ACCIONES ==========
  Future<void> _switchCamera() async {
    setState(() => _changingCameraLens = true);
    await _cameraManager.switchCamera();
    setState(() => _changingCameraLens = false);
  }

  void _toggleExposureControl() {
    setState(() {
      _showExposureControl = !_showExposureControl;
    });
  }

  Future<void> _captureImageWithOverlay() async {
    setState(() => _isCapturing = true);

    try {
      final imagePath = await _cameraManager.captureImage();
      if (imagePath == null) throw Exception('No se pudo capturar la imagen');

      final overlayImage = await _overlayCapturer.captureOverlay();

      if (overlayImage != null) {
        await _galleryManager.saveImageToGallery(
          overlayImage,
          isOverlay: true,
          onSuccess: _showSuccessMessage,
          onError: _showErrorMessage,
        );
      } else {
        final imageBytes = await File(imagePath).readAsBytes();
        await _galleryManager.saveImageToGallery(
          imageBytes,
          isOverlay: false,
          onSuccess: _showSuccessMessage,
          onError: _showErrorMessage,
        );
      }
    } catch (e) {
      _showErrorMessage('Error al capturar foto: $e');
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
