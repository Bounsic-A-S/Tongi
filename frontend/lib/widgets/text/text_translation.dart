import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:frontend/core/tongi_styles.dart';
import 'package:frontend/services/text_translation_service.dart';
import 'package:frontend/widgets/copy_button.dart';

class TextTranslation extends StatefulWidget {
  final TextEditingController inputLangController;
  final TextEditingController outputLangController;

  const TextTranslation({
    super.key,
    required this.inputLangController,
    required this.outputLangController,
  });

  @override
  State<TextTranslation> createState() => _TextTranslationState();
}

class _TextTranslationState extends State<TextTranslation> {
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();

  late DeviceTranslatorService translationService;

  @override
  void initState() {
    super.initState();
    _initTranslator();

    widget.inputLangController.addListener(_initTranslator);
    widget.outputLangController.addListener(_initTranslator);
  }

  void _initTranslator() {
    final source = widget.inputLangController.text;
    final target = widget.outputLangController.text;

    if (source.isEmpty || target.isEmpty) return;

    final stopwatch = Stopwatch()..start();

    final newService = DeviceTranslatorService(
      sourceLanguage: source,
      targetLanguage: target,
    );

    stopwatch.stop();
    print('Tiempo de ejecución: ${stopwatch.elapsedMilliseconds} ms');

    setState(() {
      translationService = newService;
    });
    _updateTranslation(_inputController.text);
  }

  void _updateTranslation(String text) {
    if (text.isEmpty) {
      _outputController.clear();
      return;
    }

    final stopwatch = Stopwatch()..start();

    translationService.translateText(text).then((translation) {
      setState(() {
        _outputController.text = translation;
      });
    });

    stopwatch.stop();
    print('Tiempo de ejecución: ${stopwatch.elapsedMilliseconds} ms');
  }

  @override
  void dispose() {
    widget.inputLangController.removeListener(_initTranslator);
    widget.outputLangController.removeListener(_initTranslator);
    super.dispose();
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
              onChanged: _updateTranslation,
            ),
            if (_inputController.text.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _inputController.clear();
                      _outputController.clear();
                    });
                  },
                  icon: const Icon(Icons.delete),
                ),
              ),
          ],
        ),

        const SizedBox(height: 15),

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
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.volume_up),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.star_border_rounded),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [CopyButton()],
        ),
      ],
    );
  }
}
