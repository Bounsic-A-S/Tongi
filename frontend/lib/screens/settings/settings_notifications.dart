import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';

class SettingsNotificationScreen extends StatelessWidget {
  const SettingsNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text("Notificaciones"),
        backgroundColor: TongiColors.primary,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: Text(
          "Aquí van los permisos de las notificaciones",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
