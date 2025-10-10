import 'package:flutter/material.dart';
import 'package:frontend/logic/services/audio/speech_service.dart';
import 'package:frontend/ui/core/tongi_colors.dart';
import 'package:frontend/ui/core/tongi_styles.dart';
import 'package:frontend/ui/widgets/copy_button.dart';
import 'package:frontend/logic/controllers/text_translation_controller.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class TextTranslation extends StatefulWidget {
  final TextTranslationController controller;

  const TextTranslation({super.key, required this.controller});

  @override
  State<TextTranslation> createState() => _TextTranslationState();
}

class _TextTranslationState extends State<TextTranslation> {
  TextTranslationController translationController = TextTranslationController();
  late final TextEditingController _outputController;
  late final TextEditingController _inputController;

  static const Map<String, String> _languageRegions = {
    'es': 'es-ES',
    'en': 'en-US',
    'de': 'de-DE',
    'it': 'it-IT',
    'jp': 'ja-JP',
  };

  Future<void> _handleSpeech(String text) async {
    try {
      if (text.isEmpty) {
        setState(() => _outputController.text = "No hay texto para sintetizar");
        return;
      }

      final lang = _languageRegions[widget.controller.targetLanguageCode] ?? 'es-ES';

      const defaultVoice = "en-US-JennyMultilingualNeural";

      final audioUrl = await TTSService.synthesizeSpeech(
        text: text,
        language: lang,
        voice: defaultVoice,
      );

      debugPrint("✅ Audio generado en: $audioUrl");

      final player = AudioPlayer();
      await player.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
      await player.play();

    } catch (e) {
      setState(() => _outputController.text = "Error al generar audio");
      debugPrint("❌ Error al generar TTS: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.controller.inputText);
    _outputController = TextEditingController(
      text: widget.controller.translatedText,
    );

    // Listen to controller changes
    widget.controller.addListener(_updateControllers);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateControllers);
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _updateControllers() {
    if (mounted) {
      if (_inputController.text != widget.controller.inputText) {
        _inputController.text = widget.controller.inputText;
      }
      if (_outputController.text != widget.controller.translatedText) {
        _outputController.text = widget.controller.translatedText;
      }
    }
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
                widget.controller.setInputText(value);
                setState(() {});
              },
            ),
            if (_inputController.text.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  onPressed: () {
                    widget.controller.clearText();
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
                  widget.controller.setInputText(clipboardData!.text!);
                }
              },
              icon: Icon(Icons.paste, color: TongiColors.darkGray),
              label: Text("Pegar", style: TongiStyles.textBody),
              style: TextButton.styleFrom(
                padding: EdgeInsets.all(0),
                overlayColor: Colors.white,
                // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                hintText: widget.controller.isTranslating
                    ? "Traduciendo..."
                    : "Translation here...",
                hintStyle: TextStyle(color: TongiColors.gray),
                filled: true,
                fillColor: TongiColors.bgGrayComponent,
                enabledBorder: TongiStyles.enabledBorder,
                focusedBorder: TongiStyles.enabledBorder,
                suffixIcon: widget.controller.isTranslating
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
                  await _handleSpeech(_outputController.text);
                }, 
                icon: Icon(Icons.volume_up)),
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
          children: [CopyButton()],
        ),
        SizedBox(height: 5),
      ],
    );
  }
}
