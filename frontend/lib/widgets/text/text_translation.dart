import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:frontend/core/tongi_styles.dart';
import 'package:frontend/services/text_translation_service.dart';
import 'package:frontend/widgets/copy_button.dart';
import 'package:frontend/services/model_manager_service.dart';

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
  final TextEditingController _outputController = TextEditingController(
    text: "",
  );
  final TextEditingController _inputController = TextEditingController(
    text: "",
  );
  late final DeviceTranslatorService translationService =
      DeviceTranslatorService(
        sourceLanguage: _inputController.text,
        targetLanguage: _outputController.text,
      );

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
              enableSuggestions: false,
              onChanged: (value) {
                setState(() {
                  if (_inputController.text.isEmpty) {
                    _outputController.text = "";
                  } else {
                    translationService
                        .translateText(_inputController.text)
                        .then((translation) {
                          _outputController.text = translation;
                        });
                  }
                });
              },
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
              onPressed: () {},
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
              child: IconButton(onPressed: () {}, icon: Icon(Icons.volume_up)),
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
