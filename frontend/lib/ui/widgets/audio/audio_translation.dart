import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/logic/controllers/past_text_translation_controller.dart';
import 'package:frontend/logic/services/audio/record_service.dart';
import 'package:frontend/logic/services/audio/transcription_service.dart';
import 'package:frontend/ui/core/tongi_colors.dart';
import 'package:frontend/ui/core/tongi_styles.dart';
import 'package:frontend/ui/widgets/audio/record_button.dart';
import 'package:frontend/ui/widgets/copy_button.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AudioTranslation extends StatefulWidget {
  final TextTranslationController controller;
  const AudioTranslation({super.key, required this.controller});
  
  

  @override
  State<AudioTranslation> createState() => _AudioTranslationState();
  
  
}

class _AudioTranslationState extends State<AudioTranslation> {
  TextTranslationController translationController = TextTranslationController();
  static const Map<String, String> _languageRegions = {
    'es': 'es-ES',
    'en': 'en-US',
    'de': 'de-DE',
    'it': 'it-IT',
    'jp': 'ja-JP',
  };
  
  final TextEditingController _inputController = TextEditingController(
    text: "",
  );
  final TextEditingController _outputController = TextEditingController(
    text: "",
  );
  final AudioPlayer audioPlayer  = AudioPlayer();

  

  Future<void> _handleRecordingComplete(File audioFile) async {
  try {
    if (!audioFile.existsSync()) {
      setState(() => _outputController.text = "Archivo no encontrado");
      return;
    }

    final sourceLang =
        _languageRegions[widget.controller.sourceLanguageCode] ?? 'es-ES';
    final targetLang =
        _languageRegions[widget.controller.targetLanguageCode] ?? 'en-US';

    final transcription = await STTService.transcribeAudio(
      audioFile,
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
    );

    setState(() => _outputController.text = transcription);
  } catch (e) {
    setState(() => _outputController.text = "Error al transcribir audio");
    debugPrint("❌ Error al transcribir: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Container(
          decoration: BoxDecoration(
            border: BoxBorder.all(color: TongiColors.border, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  RecordButton(
                  service: RecordService(),
                  onRecordingComplete: _handleRecordingComplete),
                  SizedBox(height: 15),
                  Text(
                    "Toca para iniciar a grabar.",
                    style: TongiStyles.textBody,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            border: BoxBorder.all(color: TongiColors.border, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.only(left: 20, right: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Entrada", style: TongiStyles.textFieldGrayLabel),
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.edit, color: TongiColors.darkGray),
                    label: Text(
                      "Editar",
                      style: TongiStyles.textFieldGrayLabel,
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(0),
                      iconAlignment: IconAlignment.end,
                      overlayColor: Colors.white,
                    ),
                  ),
                ],
              ),
              TextField(
                maxLines: 3,
                controller: _inputController,
                style: TongiStyles.textAudInput,
                decoration: InputDecoration(
                  hintText: "Graba un audio...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: TongiColors.gray),
                  contentPadding: EdgeInsets.all(0),
                ),
                enableSuggestions: false,
                onChanged: (value) {
                  setState(() {
                    if (_inputController.text.isEmpty) {
                      _outputController.text = "";
                    } else {
                      _outputController.text = "${_inputController.text} ##";
                    }
                  });
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            border: BoxBorder.all(color: TongiColors.border, width: 1),
            borderRadius: BorderRadius.circular(16),
            color: TongiColors.lightMainFill,
          ),
          padding: EdgeInsets.only(left: 20, right: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Traducción", style: TongiStyles.textFieldMainLabel),
                  TextButton.icon(
                    onPressed: () async {
                      final Directory documents = await getApplicationDocumentsDirectory();
                      final String filePath = p.join(documents.path, "lastRecord.wav");

                      File audioFile = File(filePath);
                      if (!audioFile.existsSync()) {
                        setState(() {
                          _outputController.text = "Archivo no encontrado";
                        });
                        return;
                      }

                      try {

                        final sourceLang = _languageRegions[widget.controller.sourceLanguageCode] ?? 'es-ES';
                        final targetLang = _languageRegions[widget.controller.targetLanguageCode] ?? 'en-US';

                        print(sourceLang +"  "+ targetLang);
                        String transcription = await STTService.transcribeAudio(audioFile,sourceLanguage: sourceLang,targetLanguage: targetLang,);
                        

                        setState(() {
                          _outputController.text = transcription;
                        });
                        await audioPlayer.setFilePath(filePath);
                        audioPlayer.setVolume(1.0);
                        await audioPlayer.play();

                      } catch (e) {
                        setState(() {
                          _outputController.text = "Error al transcribir audio";
                        });
                        print("Error al transcribir: $e");
                      }
                    },
                    icon: Icon(Icons.volume_up, color: TongiColors.primary),
                    label: Text("          "),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(0),
                      iconAlignment: IconAlignment.end,
                      overlayColor: Colors.transparent,
                      iconSize: 25,
                    ),
                  ),
                ],
              ),
              TextField(
                readOnly: true,
                maxLines: 3,
                controller: _outputController,
                style: TongiStyles.textAudOutput,
                decoration: InputDecoration(
                  hintText: "Texto traducido...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: TongiColors.gray),
                  contentPadding: EdgeInsets.all(0),
                ),
              ),
            ],
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [CopyButton()]),
      ],
    );
  }
}
