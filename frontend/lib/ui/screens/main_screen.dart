import 'package:flutter/material.dart';
import 'package:frontend/ui/screens/audio_screen.dart';
import 'package:frontend/ui/screens/settings_screen.dart';
import 'package:frontend/ui/screens/camera/camera_screen.dart';
import 'package:frontend/ui/screens/text_screen.dart';
import 'package:frontend/ui/widgets/dashboard/tongi_appbar.dart';
import 'package:frontend/ui/widgets/dashboard/tongi_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _lastIndex = 0;
  List<Widget> get _pages => [
    TextScreen(),
    CameraScreen(toggleBlockView: blockViewPop),
    AudioScreen(),
  ];
  bool isViewBlocked = false;

  void _onNavbarTapped(int index) {
    if (index != _selectedIndex) {
      _lastIndex = _selectedIndex;
      _selectedIndex = index;
      isViewBlocked = false;
    }
    setState(() {});
  }

  void blockViewPop() {
    isViewBlocked = !isViewBlocked;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == _lastIndex,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || isViewBlocked) return;
        if (_selectedIndex != _lastIndex) {
          setState(() {
            _selectedIndex = _lastIndex;
            _lastIndex = 0;
          });
        } else {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
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
            child: TongiAppbar(
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
              ? const EdgeInsets.only(left: 20, right: 20, top: 10)
              : EdgeInsets.zero,
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: TongiNavbar(
          currentIndex: _selectedIndex,
          onTap: _onNavbarTapped,
        ),
      ),
    );
  }
}
