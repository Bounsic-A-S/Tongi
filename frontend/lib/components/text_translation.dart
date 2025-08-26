import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';

class TextTranslation extends StatefulWidget {
  const TextTranslation({super.key});

  @override
  State<TextTranslation> createState() => _TextTranslationState();
}

class _TextTranslationState extends State<TextTranslation> {
  final TextEditingController _outputController = TextEditingController(
    text: "",
  );
  final TextEditingController _inputController = TextEditingController(
    text: "",
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            TextField(
              maxLines: 4,
              controller: _inputController,
              style: TextStyle(
                fontSize: 24,
                color: TongiColors.darkGray,
                fontFamily: "NotoSans",
              ),
              decoration: InputDecoration(
                hintText: "Ingrese un texto...",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: TongiColors.border, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: TongiColors.onFocus, width: 1),
                ),
                hintStyle: TextStyle(color: TongiColors.gray),
              ),
              keyboardType: TextInputType.text,
              enableSuggestions: false,
              onChanged: (value) {
                setState(() {
                  if (_inputController.text.isEmpty) {
                    _outputController.text = "";
                  } else {
                    _outputController.text =
                        "${_inputController.text} (translated xd)";
                  }
                });
              },
            ),
            if (_inputController.text.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _inputController.clear();
                      _outputController.clear();
                    });
                  },
                  icon: Icon(Icons.delete),
                ),
              ),
          ],
        ),
        SizedBox(height: 20),
        TextField(
          maxLines: 4,
          readOnly: true,
          controller: _outputController,
          style: TextStyle(
            fontSize: 24,
            color: TongiColors.textFill,
            fontFamily: "NotoSans",
          ),
          decoration: InputDecoration(
            hintText: "Translation here...",
            hintStyle: TextStyle(color: TongiColors.gray),
            filled: true,
            fillColor: TongiColors.bgGrayComponent,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: TongiColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: TongiColors.border, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
