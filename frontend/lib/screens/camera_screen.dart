import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/widgets/language_selector.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

enum CameraState { LOADING, LOADED, ERROR, PERM_DENIED }

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraState _cameraState = CameraState.LOADING;
  late List<CameraDescription> _cameras;
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    switch (_cameraState) {
      case CameraState.LOADING:
        return _buildContent(
          context,
          Center(child: CircularProgressIndicator()),
        );
      case CameraState.LOADED:
        return _buildCameraPreview(context);
      case CameraState.ERROR:
        return _buildContent(context, Center(child: Text("Error")));
      case CameraState.PERM_DENIED:
        return _buildPermDenied(context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

  Widget _buildCameraPreview(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 10,
            ),
            child: LanguageSelector(),
          ),
          CameraPreview(_cameraController),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Widget bodyContent) {
    return Scaffold(backgroundColor: Colors.white, body: bodyContent);
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

  _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras[0],
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );

    if (await _checkPermission()) {
      await _cameraController.initialize();
      if (_cameraController.value.hasError) {
        _cameraState = CameraState.ERROR;
      } else {
        _cameraState = CameraState.LOADED;
      }
    } else {
      _cameraState = CameraState.PERM_DENIED;
    }

    if (mounted) setState(() {});
  }

  Future<bool> _checkPermission() async {
    var status = await Permission.camera.status;
    status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      return false;
    }
    return true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !_cameraController.value.isInitialized) {
      _initializeCamera();
    }
  }
}
