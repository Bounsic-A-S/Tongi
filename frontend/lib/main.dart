import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:frontend/screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tongi Demo',
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: TongiColors.primary,
          title: Image.asset("assets/images/tongiWhite.png", height: 50),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.settings), color: Colors.white,),
          ],
          // leading: Image.asset("assets/images/tongiWhite.png"),
        ),
        body: DashboardScreen(),
      ),
    );
  }
}
