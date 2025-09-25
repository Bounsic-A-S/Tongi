import 'package:flutter/material.dart';
import 'package:frontend/addOns/background.dart';
import 'package:frontend/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNoti();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tongi Demo',
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}
