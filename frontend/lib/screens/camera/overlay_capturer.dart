// lib/presentation/camera/overlay_capturer.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

class OverlayCapturer {
  final GlobalKey previewKey;

  OverlayCapturer(this.previewKey);

  Future<Uint8List?> captureOverlay() async {
    try {
      final RenderRepaintBoundary boundary = 
          previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturando overlay: $e');
      return null;
    }
  }
}