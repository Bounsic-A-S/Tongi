import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("Entrada"),
        // DropdownButton(items: items, onChanged: onChanged),
        Text("Salida"),
      ],
    );
  }
}