import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:frontend/widgets/language_selector.dart';
import 'package:frontend/widgets/record_button.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LanguageSelector(),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            border: BoxBorder.all(color: TongiColors.border, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  RecordButton(),
                  SizedBox(height: 15),
                  Text("Click para iniciar a grabar."),
                  Text("Mantener."),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
