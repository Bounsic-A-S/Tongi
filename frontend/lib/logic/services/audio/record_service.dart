import 'package:record/record.dart';

class RecordService {
  final AudioRecorder _recorder;

  RecordService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> startRecording(String path) async {
    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      sampleRate: 44100,
      numChannels: 1,
      autoGain: true,
    );
    await _recorder.start(config, path: path);
  }

  Future<String?> stopRecording() => _recorder.stop();
}