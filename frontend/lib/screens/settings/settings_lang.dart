import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';

class SettingsLangScreen extends StatefulWidget {
  const SettingsLangScreen({super.key});

  @override
  State<SettingsLangScreen> createState() => _SettingsLangScreenState();
}

class _SettingsLangScreenState extends State<SettingsLangScreen> {
  String _selectedLang = "Español";

  final List<String> _langs = [
    "Español",
    "Inglés",
    "Francés",
    "Alemán",
    "Italiano",
  ];

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
        children: _langs.map((lang) {
          return RadioListTile<String>(
            title: Text(lang),
            value: lang,
            groupValue: _selectedLang, // 👈 todavía se usa en stable
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
