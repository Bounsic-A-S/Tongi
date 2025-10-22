import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/ui/core/tongi_colors.dart';
import 'package:frontend/ui/core/tongi_styles.dart';

// ignore: must_be_immutable
class CopyButton extends StatelessWidget {
  String text;
  CopyButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        copyText();
      },
      label: Text("Copiar", style: TongiStyles.textBody),
      style: TextButton.styleFrom(
        iconAlignment: IconAlignment.end,
        padding: EdgeInsets.all(0),
        overlayColor: Colors.white,
      ),
      icon: Icon(Icons.copy, color: TongiColors.darkGray),
    );
  }

  copyText() async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
