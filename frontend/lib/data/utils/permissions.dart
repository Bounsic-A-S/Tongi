import 'package:permission_handler/permission_handler.dart';

bool? isCameraPermitted;
bool? isStoragePermitted;
bool _avaliable = true;

Future<void> checkCameraPermission() async {
  var status = await Permission.camera.status;
  if (status.isDenied || status.isPermanentlyDenied) {
    isCameraPermitted = false;
  } else {
    isCameraPermitted = true;
  }
}

Future<void> askCameraPermission() async {
  if (!_avaliable) return;
  _avaliable = false;
  var status = await Permission.camera.status;
  status = await Permission.camera.request();
  if (status.isDenied || status.isPermanentlyDenied) {
    isCameraPermitted = false;
  } else {
    isCameraPermitted = true;
  }
  _avaliable = true;
}

Future<void> askStoragePermission() async {
  if (!_avaliable) return;
  _avaliable = false;
  var status = await Permission.storage.status;
  status = await Permission.storage.request();
  if (status.isDenied || status.isPermanentlyDenied) {
    isStoragePermitted = false;
  } else {
    isStoragePermitted = true;
  }
  _avaliable = true;
}
