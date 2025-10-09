import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/ui/core/tongi_languages.dart';

class LangSelectorController {
  static final LangSelectorController _instance = LangSelectorController._();
  late TextEditingController inputMenuController;
  late TextEditingController outputMenuController;

  LangSelectorController._() {
    inputMenuController = TextEditingController(text: "Español");
    outputMenuController = TextEditingController(text: "Inglés");
  }

  factory LangSelectorController() {
    return _instance;
  }

  void swapLanguages() {
    final String temp = inputMenuController.text;
    inputMenuController.text = outputMenuController.text;
    outputMenuController.text = temp;
  }

  List<DropdownMenuEntry<String>> getAvailableInputLanguages() {
    List<DropdownMenuEntry<String>> res = [];

    res.add(DropdownMenuEntry(value: "", label: "Auto"));
    tongiLanguages.forEach((key, value) {
      if (key != outputMenuController.text) {
        res.add(DropdownMenuEntry(value: value, label: key));
      }
    });
    return res;
  }

  List<DropdownMenuEntry<String>> getAvailableOutputLanguages() {
    List<DropdownMenuEntry<String>> res = [];

    tongiLanguages.forEach((key, value) {
      if (key != inputMenuController.text) {
        res.add(DropdownMenuEntry(value: value, label: key));
      }
    });
    return res;
  }

  String getInputLang() {
    String? res = tongiLanguages[inputMenuController.text];
    return res ?? "";
  }

  String getOutputLang() {
    String? res = tongiLanguages[outputMenuController.text];
    return res ?? "es";
  }

  void dispose() {
    inputMenuController.dispose();
    outputMenuController.dispose();
  }

  void saveCache() {}
}
