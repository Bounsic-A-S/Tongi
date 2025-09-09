import 'package:flutter/material.dart';
import 'package:frontend/screens/settings_screen.dart';
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

  // Body pages LIST (Carvajal aqui ponga las otras pantallas porfi :3)
  final List<Widget> _pages = [
    TextScreen(),
    Center(child: Text("Página de Buscar", style: TextStyle(fontSize: 24))),
    Center(child: Text("Página de Perfil", style: TextStyle(fontSize: 24))),
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
      appBar: TongiAppbar(
        onSettingsPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: TongiNavbar(
        currentIndex: _selectedIndex,
        onTap: _onNavbarTapped,
      ),
    );
  }
}
