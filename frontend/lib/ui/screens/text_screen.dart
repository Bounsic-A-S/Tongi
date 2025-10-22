import 'package:flutter/material.dart';
import 'package:frontend/logic/controllers/text_translation_controller.dart';
import 'package:frontend/ui/widgets/language_selector.dart';
import 'package:frontend/ui/widgets/text/text_suggestions.dart';
import 'package:frontend/ui/widgets/text/text_translation_widget.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({super.key});

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  late final TextTranslationController _translationController;

  @override
  void initState() {
    super.initState();
    _translationController = TextTranslationController();
  }

  @override
  void dispose() {
    // _translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Text("v2"),
              LanguageSelector(),
              SizedBox(height: 10),
              SizedBox(height: 10),
              TextTranslationWidget(translationController: _translationController),
              TextSuggestions(),
            ],
          ),
        ),
      ],
    );
  }
}
