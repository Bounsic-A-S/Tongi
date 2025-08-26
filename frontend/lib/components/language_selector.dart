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
  final TextEditingController inputController = TextEditingController();
  final TextEditingController outputController = TextEditingController(
    text: "Ingles",
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Text("Entrada"),
        Column(
          children: [
            Text("Entrada"),
            DropdownMenu(
              controller: inputController,
              enableFilter: true,
              hintText: "Seleccione un idioma",
              inputDecorationTheme: InputDecorationTheme(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: TongiColors.border),
                ),
              ),
              menuStyle: MenuStyle(
                backgroundColor: WidgetStateProperty.all(
                  TongiColors.bgGrayComponent,
                ),
              ),
              // initialSelection: selectedLanguageIn,
              textStyle: TextStyle(
                fontSize: 16,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
              ),
              dropdownMenuEntries: languages.map((lang) {
                return DropdownMenuEntry(value: lang, label: lang);
              }).toList(),
            ),
          ],
        ),
        Column(
          children: [
            Text("Salida"),
            DropdownMenu(
              controller: outputController,
              enableFilter: true,
              keyboardType: TextInputType.text,
              inputDecorationTheme: InputDecorationTheme(
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w700,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: TongiColors.border),
                ),
              ),
              menuStyle: MenuStyle(
                backgroundColor: WidgetStateProperty.all(
                  TongiColors.bgGrayComponent,
                ),
              ),
              hintText: "Seleccione un idioma",
              textStyle: TextStyle(
                fontSize: 16,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
              ),
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
