import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';

class SettingsNotificationScreen extends StatefulWidget {
  const SettingsNotificationScreen({super.key});

  @override
  State<SettingsNotificationScreen> createState() =>
      _SettingsNotificationScreenState();
}

class _SettingsNotificationScreenState
    extends State<SettingsNotificationScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _smsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Notificaciones"),
        backgroundColor: TongiColors.primary,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Notificaciones"),
            subtitle: const Text(
              "Recibir alertas directamente en tu dispositivo",
            ),
            activeThumbColor: TongiColors.primary,
            value: _pushEnabled,
            onChanged: (value) {
              setState(() {
                _pushEnabled = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Notificaciones por correo"),
            subtitle: const Text("Recibir resúmenes en tu email"),
            activeThumbColor: TongiColors.primary,
            value: _emailEnabled,
            onChanged: (value) {
              setState(() {
                _emailEnabled = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Notificaciones por SMS"),
            subtitle: const Text(
              "Recibir mensajes de texto con alertas importantes",
            ),
            activeThumbColor: TongiColors.primary,
            value: _smsEnabled,
            onChanged: (value) {
              setState(() {
                _smsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
