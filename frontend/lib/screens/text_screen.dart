import 'package:flutter/material.dart';
import 'package:frontend/widgets/language_selector.dart';
import 'package:frontend/widgets/text/text_suggestions.dart';
import 'package:frontend/widgets/text/text_translation.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({super.key});

  @override
  State<TextScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<TextScreen> {
  final TextEditingController inputLangController = TextEditingController();
  final TextEditingController outputLangController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              LanguageSelector(
                inputMenuController: inputLangController,
                outputMenuController: outputLangController,
              ),
              SizedBox(height: 10),
              SizedBox(height: 10),
              TextTranslation(
                inputLangController: inputLangController,
                outputLangController: outputLangController,
              ),
              TextSuggestions(),
            ],
          ),
        ),
      ],
    );
  }
}
