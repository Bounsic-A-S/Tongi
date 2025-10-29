import 'package:flutter/material.dart';
import 'package:frontend/ui/core/tongi_colors.dart';

class SettingsAboutScreen extends StatelessWidget {
  const SettingsAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Acerca de"),
        backgroundColor: TongiColors.primary,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/tongiWhite.png",
              height: 100,
              color: Colors.black,
            ),
            const SizedBox(height: 10),
            // Versión
            const Text(
              "Versión 1.0.0",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Descripción
            const Text(
              "Tongi es una aplicación móvil diseñada para traducir de todas las maneras posibles. "
              "Su nombre viene de las siglas: Translation Optimized Naturally Guided IA.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Equipo o contacto
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "Desarrollado por el equipo de Tongi\nContacto: contacto@tongi.com",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
