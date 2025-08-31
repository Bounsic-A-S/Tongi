import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';

class SettingsLangScreen extends StatelessWidget {
  const SettingsLangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text("Idioma"),
        backgroundColor: TongiColors.primary,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: Text(
          "Aquí van las configuraciones de idioma",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
