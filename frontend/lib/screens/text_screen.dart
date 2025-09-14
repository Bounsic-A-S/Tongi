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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              LanguageSelector(),
              SizedBox(height: 10),
              SizedBox(height: 10),
              TextTranslation(),
              TextSuggestions(),
            ],
          ),
        ),
      ],
    );
  }
}
