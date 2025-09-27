import 'package:flutter/material.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/terms_conditions_scren.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tongi Demo',
      debugShowCheckedModeBanner: false,
      home: TermsConditionsScreen(),
    );
  }
}
