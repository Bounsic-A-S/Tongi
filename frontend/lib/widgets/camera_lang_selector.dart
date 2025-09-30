import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:frontend/core/tongi_languages.dart';
import 'package:frontend/core/tongi_styles.dart';

class CameraLangSelector extends StatefulWidget {
  const CameraLangSelector({super.key});

  @override
  State<CameraLangSelector> createState() => _CameraLangSelectorState();
}

class _CameraLangSelectorState extends State<CameraLangSelector> {
  final TextEditingController inputMenuController = TextEditingController(
    text: availableLanguages[0].label,
  );
  final TextEditingController outputMenuController = TextEditingController(
    text: availableLanguages[1].label,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            children: [
              DropdownMenu<String>(
                controller: inputMenuController,
                // enableFilter: true,
                // requestFocusOnTap: true,
                hintText: "Seleccione un idioma",
                inputDecorationTheme: InputDecorationTheme(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TongiColors.border, width: 3),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TongiColors.border, width: 3),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                menuStyle: MenuStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                ),
                textStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontFamily: "Poppins",
                ),
                onSelected: (value) => setState(() {}),
                dropdownMenuEntries: availableLanguages
                    .where((lang) => lang.label != outputMenuController.text)
                    .map(
                      (lang) => DropdownMenuEntry(
                        value: lang.code,
                        label: lang.label,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        Column(
          children: [
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
              color: Colors.white,
            ),
          ],
        ),
        Expanded(
          child: Column(
            children: [
              DropdownMenu<String>(
                controller: outputMenuController,
                // enableFilter: true,
                // requestFocusOnTap: true,
                // keyboardType: TextInputType.text,
                inputDecorationTheme: InputDecorationTheme(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TongiColors.border, width: 3),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TongiColors.border, width: 3),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                menuStyle: MenuStyle(
                  backgroundColor: WidgetStateProperty.all(
                    TongiColors.bgGrayComponent,
                  ),
                ),
                hintText: "Seleccione un idioma",
                textStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontFamily: "Poppins",
                ),
                onSelected: (value) => setState(() {}),
                dropdownMenuEntries: availableLanguages
                    .where((lang) => lang.label != inputMenuController.text)
                    .map(
                      (lang) => DropdownMenuEntry(
                        value: lang.code,
                        label: lang.label,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
