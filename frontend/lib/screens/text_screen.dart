import 'package:flutter/material.dart';
import 'package:frontend/widgets/language_selector.dart';
import 'package:frontend/widgets/text/text_suggestions.dart';
import 'package:frontend/widgets/text/text_translation.dart';
import 'package:frontend/controllers/translation_controller.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({super.key});

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  late final TranslationController _translationController;
  
  @override
  void initState() {
    super.initState();
    _translationController = TranslationController();
  }
  
  @override
  void dispose() {
    _translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              LanguageSelector(controller: _translationController),
              SizedBox(height: 10),
              SizedBox(height: 10),
              TextTranslation(controller: _translationController),
              TextSuggestions(),
            ],
          ),
        ),
      ],
    );
  }
}
