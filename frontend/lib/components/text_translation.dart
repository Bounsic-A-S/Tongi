import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:frontend/core/tongi_styles.dart';

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
                // contentPadding: EdgeInsets.only(left: 10, top: 20, bottom: 10, right: 20),
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
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.paste, color: TongiColors.darkGray),
              label: Text(
                "Pegar",
                style: TongiStyles.textLabel,
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.all(0),
                overlayColor: Colors.white,
                // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Stack(
          children: [
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
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(onPressed: () {}, icon: Icon(Icons.volume_up)),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.star_border_rounded),
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () {},
              label: Text(
                "Copiar",
                style: TongiStyles.textLabel,
              ),
              style: TextButton.styleFrom(
                iconAlignment: IconAlignment.end,
                padding: EdgeInsets.all(0),
                overlayColor: Colors.white,
              ),
              icon: Icon(Icons.copy, color: TongiColors.darkGray),
            ),
          ],
        ),
      ],
    );
  }
}
