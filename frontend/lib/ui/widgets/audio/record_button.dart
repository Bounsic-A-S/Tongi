import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/logic/services/audio/record_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class RecordButton extends StatefulWidget {
  final RecordService service;

  final Future<void> Function(File audioFile)? onRecordingComplete;
  const RecordButton({
    super.key,
    required this.service,
    this.onRecordingComplete,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool isRecording = false;

  @override
  void dispose() {
    if (isRecording) widget.service.stopRecording();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8064E6), Color(0xFF4E99DF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: IconButton.filled(
        onPressed: () async {
          setState(() {
            isRecording = !isRecording;
          });
          if (isRecording) {
            if (await widget.service.hasPermission()) {
              final Directory dir = await getApplicationDocumentsDirectory();
              final path = p.join(dir.path, "lastRecord.wav");
              await widget.service.startRecording(path);
            }
          } else {
            await widget.service.stopRecording();
            final Directory dir = await getApplicationDocumentsDirectory();
            final path = p.join(dir.path, "lastRecord.wav");
            final audioFile = File(path);

            if (widget.onRecordingComplete != null) {
              await widget.onRecordingComplete!(audioFile);
            }
          }
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        icon: Icon(
          isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
