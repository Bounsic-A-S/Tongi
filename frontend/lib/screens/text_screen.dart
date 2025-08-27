import 'package:flutter/material.dart';
import 'package:frontend/widgets/language_selector.dart';
import 'package:frontend/widgets/text_suggestions.dart';
import 'package:frontend/widgets/text_translation.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({super.key});

  @override
  State<TextScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<TextScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Column(
        children: [
          LanguageSelector(),
          SizedBox(height: 10),
          SizedBox(height: 10),
          TextTranslation(),
          TextSuggestions(),
        ],
      ),
    );
  }
}
