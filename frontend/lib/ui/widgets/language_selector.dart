import 'package:flutter/material.dart';
import 'package:frontend/logic/controllers/lang_selector_controller.dart';
import 'package:frontend/ui/core/tongi_colors.dart';
import 'package:frontend/ui/core/tongi_styles.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  LangSelectorController controller = LangSelectorController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            children: [
              SizedBox(height: 20, child: Text("Entrada")),
              DropdownMenu<String>(
                controller: controller.inputMenuController,
                // enableFilter: true,
                // requestFocusOnTap: true,
                hintText: "Seleccione un idioma",
                inputDecorationTheme: InputDecorationTheme(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TongiColors.border),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
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
                onSelected: (value) {
                  if (value != null) {
                    controller.setInputLang(value);
                    setState(() {});
                  }
                },
                dropdownMenuEntries: controller.getAvailableInputLanguages(),
              ),
            ],
          ),
        ),
        Column(
          children: [
            SizedBox(height: 20),
            IconButton(
              onPressed: () {
                setState(() {
                  controller.swapLanguages();
                });
              },
              icon: Icon(Icons.swap_horiz_outlined),
              iconSize: 30,
              color: TongiColors.accent,
            ),
          ],
        ),
        Expanded(
          child: Column(
            children: [
              SizedBox(height: 20, child: Text("Salida")),
              DropdownMenu<String>(
                controller: controller.outputMenuController,
                // enableFilter: true,
                // requestFocusOnTap: true,
                inputDecorationTheme: InputDecorationTheme(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TongiColors.border),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
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
                onSelected: (value) {
                  if (value != null) {
                    controller.setOutputLang(value);
                    setState(() {});
                  }
                },
                dropdownMenuEntries: controller.getAvailableOutputLanguages(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
