import 'package:flutter/material.dart';
import 'package:frontend/ui/core/tongi_languages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LangSelectorController {
  static final LangSelectorController _instance = LangSelectorController._();
  late TextEditingController inputMenuController;
  late TextEditingController outputMenuController;
  late Function swapText;
  late Function notify;
  late String _sourceCodeLang;
  late String _targetCodeLang;

  LangSelectorController._() {
    inputMenuController = TextEditingController();
    outputMenuController = TextEditingController();
    loadLanguages();
    swapText = () {};
    notify = () {};
  }

  factory LangSelectorController() {
    return _instance;
  }

  void swapLanguages() {
    // code
    String temp = _sourceCodeLang;
    _sourceCodeLang = _targetCodeLang;
    _targetCodeLang = temp;
    // label
    temp = inputMenuController.text;
    inputMenuController.text = outputMenuController.text;
    outputMenuController.text = (_targetCodeLang.isEmpty) ? "" : temp;
    swapText();
    saveLanguages();
  }

  void setLanguage() {
    saveLanguages();
    notify();
  }

  void setInputLang(String code) {
    if (code.isEmpty) {
      inputMenuController.text = "Auto";
      _sourceCodeLang = "";
    } else {
      inputMenuController.text =
          tongiLanguages[code] ?? inputMenuController.text;
    }
    setLanguage();
  }

  void setOutputLang(String code) {
    if (code.isEmpty) {
      _targetCodeLang = "";
      outputMenuController.text = "";
    } else {
      String? lang = tongiLanguages[code];
      if (lang != null) {
        _targetCodeLang = code;
        outputMenuController.text = lang;
      }
    }
    setLanguage();
  }

  List<DropdownMenuEntry<String>> getAvailableInputLanguages() {
    List<DropdownMenuEntry<String>> res = [];

    res.add(DropdownMenuEntry(value: "", label: "Auto"));
    tongiLanguages.forEach((key, value) {
      if (value != outputMenuController.text) {
        res.add(DropdownMenuEntry(value: key, label: value));
      }
    });
    return res;
  }

  List<DropdownMenuEntry<String>> getAvailableOutputLanguages() {
    List<DropdownMenuEntry<String>> res = [];

    tongiLanguages.forEach((key, value) {
      if (value != inputMenuController.text) {
        res.add(DropdownMenuEntry(value: key, label: value));
      }
    });
    return res;
  }

  String getInputLang() {
    return _sourceCodeLang;
  }

  String getOutputLang() {
    return _targetCodeLang;
  }

  void dispose() {
    inputMenuController.dispose();
    outputMenuController.dispose();
  }

  Future<void> saveLanguages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('source_language', _sourceCodeLang);
      await prefs.setString('target_language', _targetCodeLang);
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> loadLanguages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sourceCodeLang = prefs.getString('source_language') ?? 'es';
      _targetCodeLang = prefs.getString('target_language') ?? 'en';
      setInputLang(_sourceCodeLang);
      setOutputLang(_targetCodeLang);
    } catch (e) {
      inputMenuController.text = 'es';
      outputMenuController.text = 'en';
    }
  }

  Future<void> clearPreferrences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('source_language');
    await prefs.remove('target_language');
  }
}
