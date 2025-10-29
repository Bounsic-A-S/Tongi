import 'package:flutter/material.dart';
import 'package:frontend/logic/controllers/speech_translation_comtroller.dart';
import 'package:frontend/logic/controllers/text_translation_controller.dart';
import 'package:frontend/ui/widgets/language_selector.dart';
import 'package:frontend/ui/widgets/text/text_translation_widget.dart';

class TextScreen extends StatelessWidget {
  late final TextTranslationController _translationController;
  late final TTSController _speechController;

  TextScreen({super.key}) {
    this._translationController = TextTranslationController();
    this._speechController = TTSController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Text("data"),
              LanguageSelector(),
              SizedBox(height: 10),
              SizedBox(height: 10),
              TextTranslationWidget(
                translationController: _translationController,
                speechController: _speechController,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
