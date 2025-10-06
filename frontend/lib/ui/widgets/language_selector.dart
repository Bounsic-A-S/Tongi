import 'package:flutter/material.dart';
import 'package:frontend/ui/core/tongi_colors.dart';
import 'package:frontend/ui/core/tongi_languages.dart';
import 'package:frontend/ui/core/tongi_styles.dart';
import 'package:frontend/logic/controllers/translation_controller.dart';

class LanguageSelector extends StatefulWidget {
  final TranslationController controller;
  
  const LanguageSelector({super.key, required this.controller});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late final TextEditingController inputMenuController;
  late final TextEditingController outputMenuController;
  
  @override
  void initState() {
    super.initState();
    inputMenuController = TextEditingController(
      text: widget.controller.sourceLanguageLabel,
    );
    outputMenuController = TextEditingController(
      text: widget.controller.targetLanguageLabel,
    );
    
    // Listen to controller changes
    widget.controller.addListener(_updateControllers);
  }
  
  @override
  void dispose() {
    widget.controller.removeListener(_updateControllers);
    inputMenuController.dispose();
    outputMenuController.dispose();
    super.dispose();
  }
  
  void _updateControllers() {
    if (mounted) {
      inputMenuController.text = widget.controller.sourceLanguageLabel;
      outputMenuController.text = widget.controller.targetLanguageLabel;
    }
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
                controller: inputMenuController,
                enableFilter: true,
                requestFocusOnTap: true,
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
                    widget.controller.setSourceLanguage(value);
                  }
                },
                dropdownMenuEntries: widget.controller
                    .getAvailableSourceLanguages()
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
            SizedBox(height: 20),
            IconButton(
              onPressed: () {
                widget.controller.swapLanguages();
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
                controller: outputMenuController,
                enableFilter: true,
                requestFocusOnTap: true,
                keyboardType: TextInputType.text,
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
                    widget.controller.setTargetLanguage(value);
                  }
                },
                dropdownMenuEntries: widget.controller
                    .getAvailableTargetLanguages()
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
