import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Navbar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: TongiColors.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.text_fields_rounded),
          label: 'Texto',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Camara'),
        BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Audio'),
      ],
    );
  }
}
