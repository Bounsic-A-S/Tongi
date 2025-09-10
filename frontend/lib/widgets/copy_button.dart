import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:frontend/core/tongi_styles.dart';

class CopyButton extends StatelessWidget {
  const CopyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      label: Text("Copiar", style: TongiStyles.textBody),
      style: TextButton.styleFrom(
        iconAlignment: IconAlignment.end,
        padding: EdgeInsets.all(0),
        overlayColor: Colors.white,
      ),
      icon: Icon(Icons.copy, color: TongiColors.darkGray),
    );
  }
}
