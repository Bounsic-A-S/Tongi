import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraManager {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;

  // Configuración de cámara
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;

  // Callbacks
  final Function(InputImage inputImage)? onImage;
  final Function()? onCameraFeedReady;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;

  bool initialized = false;

  CameraManager({
    this.onImage,
    this.onCameraFeedReady,
    this.onCameraLensDirectionChanged,
    CameraLensDirection initialCameraLensDirection = CameraLensDirection.back,
  }) {
    _initialize(initialCameraLensDirection);
  }

  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  double get currentExposureOffset => _currentExposureOffset;
  double get minAvailableExposureOffset => _minAvailableExposureOffset;
  double get maxAvailableExposureOffset => _maxAvailableExposureOffset;
  double get minZoomLevel => _minAvailableZoom;
  double get maxZoomLevel => _maxAvailableZoom;

  Future<void> _initialize(CameraLensDirection initialDirection) async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }

    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == initialDirection) {
        _cameraIndex = i;
        break;
      }
    }

    if (_cameraIndex != -1) {
      await _startLiveFeed();
    }
    initialized = true;
  }

  Future<void> _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();

    // Configurar zoom
    _minAvailableZoom = await _controller!.getMinZoomLevel();
    _maxAvailableZoom = await _controller!.getMaxZoomLevel();

    // Configurar exposición
    _minAvailableExposureOffset = await _controller!.getMinExposureOffset();
    _maxAvailableExposureOffset = await _controller!.getMaxExposureOffset();
    _currentExposureOffset = 0.0;

    // Iniciar stream de imágenes
    await _controller!.startImageStream(_processCameraImage);

    onCameraFeedReady?.call();
    onCameraLensDirectionChanged?.call(camera.lensDirection);
  }

  Future<void> switchCamera() async {
    if (_cameras.length <= 1) return;

    await _stopLiveFeed();
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _startLiveFeed();
  }

  Future<void> setZoomLevel(double zoomLevel) async {
    if (_controller == null) return;

    final clampedZoom = zoomLevel.clamp(_minAvailableZoom, _maxAvailableZoom);
    await _controller!.setZoomLevel(clampedZoom);
  }

  Future<void> setExposureOffset(double offset) async {
    if (_controller == null) return;

    final clampedOffset = offset.clamp(
      _minAvailableExposureOffset,
      _maxAvailableExposureOffset,
    );
    await _controller!.setExposureOffset(clampedOffset);
    _currentExposureOffset = clampedOffset;
  }

  Future<String?> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      final XFile capturedFile = await _controller!.takePicture();
      return capturedFile.path;
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage != null) {
      onImage?.call(inputImage);
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _cameras[_cameraIndex];
    // final sensorOrientation = camera.sensorOrientation;

    // Calcular rotación
    final rotation = _calculateImageRotation(camera);
    if (rotation == null) return null;

    // Verificar formato
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    if (Platform.isAndroid && format != InputImageFormat.nv21) return null;
    if (Platform.isIOS && format != InputImageFormat.bgra8888) return null;
    if (image.planes.length != 1) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  InputImageRotation? _calculateImageRotation(CameraDescription camera) {
    if (Platform.isIOS) {
      return InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    } else if (Platform.isAndroid) {
      const orientations = {
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270,
      };

      final deviceOrientation = _controller!.value.deviceOrientation;
      final rotationCompensation = orientations[deviceOrientation];
      if (rotationCompensation == null) return null;

      int finalRotation;
      if (camera.lensDirection == CameraLensDirection.front) {
        finalRotation = (camera.sensorOrientation + rotationCompensation) % 360;
      } else {
        finalRotation =
            (camera.sensorOrientation - rotationCompensation + 360) % 360;
      }

      return InputImageRotationValue.fromRawValue(finalRotation);
    }
    return null;
  }

  Future<void> _stopLiveFeed() async {
    if (initialized) {
      await _controller?.stopImageStream();
      await _controller?.dispose();
      _controller = null;
    }
  }

  Future<void> dispose() async {
    await _stopLiveFeed();
  }
}
