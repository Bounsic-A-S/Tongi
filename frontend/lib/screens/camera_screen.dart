import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

enum CameraState { LOADING, LOADED, ERROR, PERMDENIED }

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
        return _buildContent(context, CameraPreview(_cameraController));
      case CameraState.ERROR:
        return _buildContent(context, Center(child: Text("Error")));
      case CameraState.PERMDENIED:
        return _buildContent(
          context,
          Center(
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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_cameraController.value.isInitialized) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

  Widget _buildContent(BuildContext context, Widget body) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void showInSnackBarSettings(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
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
      _cameraState = CameraState.PERMDENIED;
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
}
