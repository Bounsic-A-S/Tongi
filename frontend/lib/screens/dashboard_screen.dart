import 'package:flutter/material.dart';
import 'package:frontend/components/language_selector.dart';
import 'package:frontend/components/text_suggestions.dart';
import 'package:frontend/components/text_translation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
