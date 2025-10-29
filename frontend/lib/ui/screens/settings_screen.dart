import 'package:flutter/material.dart';
import 'package:frontend/ui/core/tongi_colors.dart';
import 'package:frontend/ui/screens/settings/settings_about.dart';
import 'package:frontend/ui/screens/settings/settings_lang.dart';
import 'package:frontend/ui/screens/settings/settings_notifications.dart';
import 'package:frontend/ui/screens/settings/settings_models_screen.dart';
import 'package:frontend/ui/screens/terms_conditions_scren.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text("Configuraciones"),
        backgroundColor: TongiColors.primary,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: "Poppins",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.language),
              title: Text("Idioma"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsLangScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.offline_pin),
              title: Text("Modelos sin conexión"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsModelsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Notificaciones"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsNotificationScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("Acerca de"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsAboutScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shield),
              title: Text("Términos & Condiciones"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FullTermsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        child: Text(
          "© 2025 Tongi. Todos los derechos reservados",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
    );
  }
}
