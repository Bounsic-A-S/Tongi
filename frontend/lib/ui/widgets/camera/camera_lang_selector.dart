import 'package:flutter/material.dart';
import 'package:frontend/logic/controllers/lang_selector_controller.dart';
import 'package:frontend/ui/core/tongi_colors.dart';

class CameraLangSelector extends StatefulWidget {
  const CameraLangSelector({super.key});

  @override
  State<CameraLangSelector> createState() => _CameraLangSelectorState();
}

class _CameraLangSelectorState extends State<CameraLangSelector> {
  LangSelectorController controller = LangSelectorController();

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
                controller: controller.inputMenuController,
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
                dropdownMenuEntries: controller.getAvailableInputLanguages(),
              ),
            ],
          ),
        ),
        Column(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  controller.swapLanguages();
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
                controller: controller.outputMenuController,
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
                dropdownMenuEntries: controller.getAvailableOutputLanguages(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
