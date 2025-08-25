import 'package:flutter/material.dart';

class TextTranslation extends StatefulWidget {
  const TextTranslation({super.key});

  @override
  State<TextTranslation> createState() => _TextTranslationState();
}

class _TextTranslationState extends State<TextTranslation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          maxLines: 4,
          style: TextStyle(),
          decoration: InputDecoration(
            hintText: "Ingrese un texto...",
            border: OutlineInputBorder(),
          ),
        ),
        TextField(),
      ],
    );
  }
}
