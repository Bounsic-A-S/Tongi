import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/logic/controllers/auidio_translation_controller.dart';
import 'package:frontend/logic/controllers/lang_selector_controller.dart';
import 'package:frontend/logic/controllers/speech_translation_comtroller.dart';
import 'package:frontend/logic/controllers/text_translation_controller.dart';
import 'package:frontend/logic/services/audio/record_service.dart';
import 'package:frontend/ui/core/tongi_colors.dart';
import 'package:frontend/ui/core/tongi_styles.dart';
import 'package:frontend/ui/widgets/audio/record_button.dart';
import 'package:frontend/ui/widgets/copy_button.dart';
import 'package:just_audio/just_audio.dart';

class AudioTranslation extends StatefulWidget {
  final STTController controller;
  final TTSController ttsController;
  const AudioTranslation({
    super.key,
    required this.controller,
    required this.ttsController,
  });

  @override
  State<AudioTranslation> createState() => _AudioTranslationState();
}

class _AudioTranslationState extends State<AudioTranslation> {
  TextTranslationController textTranslationController =
      TextTranslationController();

  final TextEditingController _inputController = TextEditingController(
    text: "",
  );
  final TextEditingController _outputController = TextEditingController(
    text: "",
  );
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    LangSelectorController().addListener(_updateLanguage);
    LangSelectorController().swapText = () {};
    super.initState();
  }

  @override
  void dispose() {
    LangSelectorController().removeListener(_updateLanguage);
    super.dispose();
  }

  _updateLanguage() {
    _outputController.clear();
    _translateText(_inputController.text);
  }

  Future<void> _translateText(String text) async {
    String res = await textTranslationController.translateText(text);
    _outputController.text = res;
    _safeSetState();
  }

  Future<void> _processAudio(File audioFile) async {
    if (!audioFile.existsSync()) {
      _showError("Archivo no encontrado");
      return;
    }

    _inputController.text = "Procesando...";
    _outputController.text = "Traduciendo...";

    try {
      // 1️⃣ Transcribe el audio original
      final originalText = await widget.controller.transcribeAudio(audioFile);

      _inputController.text = originalText;

      // 2️⃣ Traduce el audio a otro idioma
      final translatedText = await widget.controller.transcribeAndTranslate(
        audioFile,
      );

      _outputController.text = translatedText;
    } catch (e) {
      _showError("❌ Error al procesar el audio: $e");
    }
  }

  Future<void> _playSpeech(String text) async {
    if (text.trim().isEmpty) {
      _showError("No hay texto para sintetizar");
      return;
    }

    try {
      final audioUrl = await widget.ttsController.synthesizeSpeech(text);
      debugPrint("✅ Audio generado: $audioUrl");

      await audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
      await audioPlayer.play();
    } catch (e) {
      _showError("❌ Error al reproducir voz: $e");
    }
  }

  void _showError(String message) {
    _outputController.text = message;
    debugPrint(message);
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
                    onRecordingComplete: _processAudio,
                  ),
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
                keyboardType: TextInputType.text,
                enableSuggestions: true,
                onChanged: (value) {
                  _translateText(value);
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
          padding: EdgeInsets.only(left: 20, right: 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text("Traducción", style: TongiStyles.textFieldMainLabel),
                  IconButton(
                    onPressed: () async {
                      await _playSpeech(_outputController.text);
                    },
                    icon: Icon(Icons.volume_up, color: TongiColors.primary),
                    style: TextButton.styleFrom(
                      iconAlignment: IconAlignment.end,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [CopyButton(text: _outputController.text)],
        ),
      ],
    );
  }

  void _safeSetState() {
    if (mounted) {
      setState(() {});
    }
  }
}
