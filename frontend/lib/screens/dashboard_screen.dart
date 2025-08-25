import 'package:flutter/material.dart';
import 'package:frontend/components/language_selector.dart';
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
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          LanguageSelector(),
          TextTranslation(),
        ],
      ),
    );
  }
}