import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:frontend/core/tongi_styles.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final List<String> languages = ["Español", "Ingles", "Alemán", "Java", "C++"];
  final TextEditingController inputMenuController = TextEditingController();
  final TextEditingController outputMenuController = TextEditingController(
    text: "Ingles",
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            SizedBox(height: 20, child: Text("Entrada")),
            DropdownMenu(
              controller: inputMenuController,
              enableFilter: true,
              hintText: "Seleccione un idioma",
              inputDecorationTheme: InputDecorationTheme(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: TongiColors.border),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              menuStyle: MenuStyle(
                backgroundColor: WidgetStateProperty.all(
                  TongiColors.bgGrayComponent,
                ),
              ),
              textStyle: TongiStyles.textLabel,
              dropdownMenuEntries: languages.map((lang) {
                return DropdownMenuEntry(value: lang, label: lang);
              }).toList(),
            ),
          ],
        ),
        Column(
          children: [
            SizedBox(height: 20),
            IconButton(
              onPressed: () {
                setState(() {
                  String temp = inputMenuController.text;
                  inputMenuController.text = outputMenuController.text;
                  outputMenuController.text = temp;
                });
              },
              icon: Icon(Icons.swap_horiz_outlined),
              iconSize: 30,
              color: TongiColors.accent,
            ),
          ],
        ),
        Column(
          children: [
            SizedBox(height: 20, child: Text("Salida")),
            DropdownMenu(
              controller: outputMenuController,
              enableFilter: true,
              keyboardType: TextInputType.text,
              inputDecorationTheme: InputDecorationTheme(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: TongiColors.border),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              menuStyle: MenuStyle(
                backgroundColor: WidgetStateProperty.all(
                  TongiColors.bgGrayComponent,
                ),
              ),
              hintText: "Seleccione un idioma",
              textStyle: TongiStyles.textLabel,
              dropdownMenuEntries: languages.map((lang) {
                return DropdownMenuEntry(value: lang, label: lang);
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
