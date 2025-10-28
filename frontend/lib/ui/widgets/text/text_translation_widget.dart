import 'package:flutter/material.dart';
import 'package:frontend/logic/controllers/lang_selector_controller.dart';
import 'package:frontend/logic/controllers/speech_translation_comtroller.dart';
import 'package:frontend/logic/controllers/text_translation_controller.dart';
import 'package:frontend/ui/core/tongi_colors.dart';
import 'package:frontend/ui/core/tongi_styles.dart';
import 'package:frontend/ui/widgets/copy_button.dart';
import 'package:flutter/services.dart';
import 'package:frontend/ui/widgets/text/text_suggestions.dart';
import 'package:just_audio/just_audio.dart';

class TextTranslationWidget extends StatefulWidget {
  final TextTranslationController translationController;
  final TTSController speechController;

  const TextTranslationWidget({
    super.key,
    required this.translationController,
    required this.speechController,
  });

  @override
  State<TextTranslationWidget> createState() => _TextTranslationWidgetState();
}

class _TextTranslationWidgetState extends State<TextTranslationWidget> {
  late final TextEditingController _outputController;
  late final TextEditingController _inputController;
  late bool _lastEmpty;
  late int _lastRequestId;
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _outputController = TextEditingController();
    _lastEmpty = false;
    _lastRequestId = 0;
    LangSelectorController().swapText = _swap;
    LangSelectorController().notify = _newLanguage;
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  Future<void> _translate(String text) async {
    int requestId = ++_lastRequestId;

    if (text.isEmpty) {
      _outputController.clear();
      _lastEmpty = true;
    } else {
      _lastEmpty = false;
      if (_outputController.text.isNotEmpty &&
          !_outputController.text.endsWith("...")) {
        _outputController.text += "...";
      }
      String tt = await widget.translationController.translateText(
        text,
        id: requestId,
      );
      if (!_lastEmpty &&
          requestId == widget.translationController.getLastId()) {
        _outputController.text = tt;
      }
    }
    setState(() {});
  }

  _reset() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
      _lastRequestId = 0;
      widget.translationController.resetId();
      _lastEmpty = true;
    });
  }

  Future<void> _playSpeech(String text) async {
    if (text.trim().isEmpty) {
      _showError("No hay texto para sintetizar");
      return;
    }

    try {
      final audioUrl = await widget.speechController.synthesizeSpeech(text);
      debugPrint("✅ Audio generado: $audioUrl");

      await audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
      await audioPlayer.play();
    } catch (e) {
      _showError("❌ Error al reproducir voz: $e");
    }
  }

  void _showError(String message) {
    setState(() => _outputController.text = message);
    debugPrint(message);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            TextField(
              maxLines: 4,
              controller: _inputController,
              style: TongiStyles.textInput,
              decoration: InputDecoration(
                hintText: "Ingrese un texto...",
                enabledBorder: TongiStyles.enabledBorder,
                focusedBorder: TongiStyles.focusedBorder,
                hintStyle: TextStyle(color: TongiColors.gray),
              ),
              keyboardType: TextInputType.text,
              enableSuggestions: true,
              onChanged: (value) {
                _translate(value);
              },
            ),
            if (_inputController.text.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  onPressed: () {
                    _reset();
                  },
                  icon: Icon(Icons.delete),
                ),
              ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () async {
                final clipboardData = await Clipboard.getData('text/plain');
                if (clipboardData?.text != null) {
                  _inputController.text = clipboardData!.text!;
                }
              },
              icon: Icon(Icons.paste, color: TongiColors.darkGray),
              label: Text("Pegar", style: TongiStyles.textBody),
              style: TextButton.styleFrom(
                padding: EdgeInsets.all(0),
                overlayColor: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Stack(
          children: [
            TextField(
              maxLines: 4,
              readOnly: true,
              controller: _outputController,
              style: TongiStyles.textOutput,
              decoration: InputDecoration(
                hintText: "Translation here...",
                hintStyle: TextStyle(color: TongiColors.gray),
                filled: true,
                fillColor: TongiColors.bgGrayComponent,
                enabledBorder: TongiStyles.enabledBorder,
                focusedBorder: TongiStyles.enabledBorder,
                suffixIcon: widget.translationController.isTranslating
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              TongiColors.accent,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () async {
                  await _playSpeech(_outputController.text);
                },
                icon: Icon(Icons.volume_up),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.star_border_rounded),
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [CopyButton(text: _outputController.text)],
        ),
        SizedBox(height: 5),
        TextSuggestions(onTap: _onTapSuggestion),
      ],
    );
  }

  _onTapSuggestion(String suggesttext) {
    _inputController.text = suggesttext;
    _translate(_inputController.text);
  }

  _swap() {
    debugPrint(" Swap");
    _inputController.text = _outputController.text;
    _outputController.clear();
    _translate(_inputController.text);
  }

  _newLanguage() {
    _outputController.clear();
    _translate(_inputController.text);
  }
}
