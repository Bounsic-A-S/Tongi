import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:frontend/screens/audio_screen.dart';
import 'package:frontend/screens/camera_screen.dart';
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
  final List<Widget> _pages = [TextScreen(), CameraScreen(), AudioScreen()];

  void _onNavbarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1.0,
                child: child,
              ),
            );
          },
          child:
              _selectedIndex ==
                  1 // camera index
              // ? const SizedBox.shrink(key: ValueKey("emptyAppBar"))
              ? Container(
                  height: MediaQuery.of(context).padding.top,
                  color: TongiColors.primary,
                )
              : TongiAppbar(
                  key: const ValueKey("tongiAppBar"),
                  onSettingsPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
        ),
      ),
      body: Padding(
        padding: _selectedIndex != 1
            ? EdgeInsets.only(left: 20, right: 20, top: 10)
            : EdgeInsetsGeometry.all(0),
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: TongiNavbar(
        currentIndex: _selectedIndex,
        onTap: _onNavbarTapped,
      ),
    );
  }
}
