import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';

class SettingsAboutScreen extends StatelessWidget {
  const SettingsAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text("Acerca de"),
        backgroundColor: TongiColors.primary,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: Text(
          "Tongi es una aplicación movil diseñada para traducir de todas las maneras posibles, su nombre viene de las siglas Translation Optimized Naturally Guided IA",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
