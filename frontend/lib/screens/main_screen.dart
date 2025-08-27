import 'package:flutter/material.dart';
import 'package:frontend/components/dashboard/navbar.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:frontend/screens/text_screen.dart';

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
      appBar: AppBar(
        backgroundColor: TongiColors.primary,
        title: Image.asset("assets/images/tongiWhite.png", height: 50),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings),
            color: Colors.white,
          ),
        ],
        // leading: Image.asset("assets/images/tongiWhite.png"),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Navbar(
        currentIndex: _selectedIndex,
        onTap: _onNavbarTapped,
      ),
    );
  }
}
