import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';

class RecordButton extends StatefulWidget {
  const RecordButton({super.key});

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  final record = AudioRecorder();
  final recordConfig = RecordConfig(
    encoder: AudioEncoder.aacLc,
    sampleRate: 44100,
    numChannels: 1,
    autoGain: true,
    // echoCancel: true,
    // noiseSuppress: true,
  );
  bool isRecording = false;

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
            if (await record.hasPermission()) {
              final Directory documents =
                  await getApplicationDocumentsDirectory();
              final String filePath = p.join(
                documents.path,
                "lastRecord.aacLc",
              );
              await record.start(recordConfig, path: filePath);
            }
          } else {
            await record.stop();
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
