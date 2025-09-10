import 'package:flutter/material.dart';
import 'package:frontend/screens/audio_screen.dart';
import 'package:frontend/screens/text_screen.dart';
import 'package:frontend/widgets/dashboard/tongi_appbar.dart';
import 'package:frontend/widgets/dashboard/tongi_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Aquí defines las páginas del body
  final List<Widget> _pages = [
    TextScreen(),
    Center(child: Text("Página de ff", style: TextStyle(fontSize: 24))),
    AudioScreen(),
  ];

  void _onNavbarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TongiAppbar(onSettingsPressed: () => {print("Settings Pressed")}),
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 10),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: TongiNavbar(
        currentIndex: _selectedIndex,
        onTap: _onNavbarTapped,
      ),
    );
  }
}
