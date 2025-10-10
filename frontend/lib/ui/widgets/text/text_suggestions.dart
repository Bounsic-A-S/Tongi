import 'package:flutter/material.dart';
import 'package:frontend/ui/core/tongi_styles.dart';

class TextSuggestions extends StatefulWidget {
  const TextSuggestions({super.key});

  @override
  State<TextSuggestions> createState() => _TextSuggestionsState();
}

class _TextSuggestionsState extends State<TextSuggestions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Traducciones rápidas", style: TongiStyles.textTitle),
        SizedBox(height: 5),
        Wrap(
          children: [
            SuggestButton(title: "Hello"),
            SizedBox(width: 10),
            SuggestButton(title: "What's up"),
            SizedBox(width: 10),
            SuggestButton(title: "How can I"),
          ],
        ),
      ],
    );
  }
}

class SuggestButton extends StatelessWidget {
  final String title;
  const SuggestButton({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 15)),
        elevation: WidgetStateProperty.all(0.5),
        minimumSize: WidgetStateProperty.all(Size(0, 30)),
      ),
      child: Text(title, style: TongiStyles.textBody),
    );
  }
}
