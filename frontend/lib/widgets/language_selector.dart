import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:frontend/core/tongi_languages.dart';
import 'package:frontend/core/tongi_styles.dart';
import 'package:frontend/offline_check_controller.dart';
import 'package:frontend/services/model_manager_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class LanguageSelector extends StatefulWidget {
  final TextEditingController inputMenuController;
  final TextEditingController outputMenuController;

  const LanguageSelector({
    super.key,
    required this.inputMenuController,
    required this.outputMenuController,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  static OfflineCheckController offlineCheckController =
      OfflineCheckController();
  List<MapEntry<String, String>> _availableLanguages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    offlineCheckController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 20, child: Text("Entrada")),
                DropdownMenu<String>(
                  controller: widget.inputMenuController,
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
                    widget.inputMenuController.text = value ?? "";
                    setState(() {});
                  },
                  dropdownMenuEntries: _availableLanguages
                      .where(
                        (lang) => lang.key != widget.inputMenuController.text,
                      )
                      .map(
                        (lang) => DropdownMenuEntry(
                          value: lang.value,
                          label: lang.key,
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
                  setState(() {
                    String temp = widget.outputMenuController.text;
                    widget.inputMenuController.text =
                        widget.outputMenuController.text;
                    widget.outputMenuController.text = temp;
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
                  controller: widget.outputMenuController,
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
                    widget.outputMenuController.text = value ?? "";
                    setState(() {});
                  },
                  dropdownMenuEntries: _availableLanguages
                      .where(
                        (lang) => lang.key != widget.inputMenuController.text,
                      )
                      .map(
                        (lang) => DropdownMenuEntry(
                          value: lang.value,
                          label: lang.key,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
