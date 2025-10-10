import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:frontend/core/tongi_languages.dart';

class SettingsLangScreen extends StatefulWidget {
  const SettingsLangScreen({super.key});

  @override
  State<SettingsLangScreen> createState() => _SettingsLangScreenState();
}

class _SettingsLangScreenState extends State<SettingsLangScreen> {
  String _selectedLang = completeLanguages.keys.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Idioma"),
        backgroundColor: TongiColors.primary,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        children: completeLanguages.entries.map((lang) {
          return RadioListTile<String>(
            title: Text(lang.key),
            value: lang.value,
            groupValue: _selectedLang,
            onChanged: (value) {
              setState(() {
                _selectedLang = value!;
              });
            },
          );
        }).toList(),
      ),
    );
  }
}
