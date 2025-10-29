import 'package:flutter/material.dart';
import 'package:frontend/ui/core/tongi_languages.dart';
import 'package:frontend/logic/controllers/offline_check_controller.dart';
import 'package:frontend/logic/controllers/model_manager_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LangSelectorController extends ChangeNotifier {
  static final LangSelectorController _instance = LangSelectorController._();
  late TextEditingController inputMenuController;
  late TextEditingController outputMenuController;
  late Function swapText;
  late String _sourceCodeLang;
  late String _targetCodeLang;
  late final OfflineCheckController _offlineController;
  final _modelManager = OnDeviceTranslatorModelManager();

  /// Current available languages (code -> label).
  late Map<String, String> _availableLanguages;

  LangSelectorController._() {
    inputMenuController = TextEditingController();
    outputMenuController = TextEditingController();
    loadLanguages();
    swapText = () {};
    // Start offline watcher and refresh available languages accordingly.
    _offlineController = OfflineCheckController();
    _offlineController.addListener(_onOfflineChanged);
    // Initialize available languages based on current connectivity.
    _refreshAvailableLanguages();
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

  Future<void> _onOfflineChanged() async {
    // Called when OfflineCheckController updates (connectivity / available models)
    // Wait for available languages to be refreshed before notifying UI so
    // widgets rebuild with the updated list immediately.
    await _refreshAvailableLanguages();
    notifyListeners();
  }

  Future<void> _refreshAvailableLanguages() async {
    try {
      if (_offlineController.isOffline) {
        print('Is it me');
        final downloaded = await _modelManager.loadDownloadedLanguages();
        // downloaded is Map<code,label>
        _availableLanguages = Map<String, String>.from(downloaded);
      } else {
        print('Or me');
        _availableLanguages = tongiLanguages;
      }
    } catch (_) {
      print('Or is it me');
      _availableLanguages = tongiLanguages;
    }
  }

  /// Whether the device is currently offline according to the internal
  /// `OfflineCheckController`.
  bool get isOffline => _offlineController.isOffline;

  /// Returns the currently available languages mapping (code -> label).
  Map<String, String> get availableLanguagesMap => _availableLanguages;

  void setLanguage() {
    saveLanguages();
    notifyListeners();
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
    final List<DropdownMenuEntry<String>> res = [];
    _availableLanguages.forEach((key, value) {
      if (value != outputMenuController.text) {
        res.add(DropdownMenuEntry(value: key, label: value));
      }
    });
    return res;
  }

  List<DropdownMenuEntry<String>> getAvailableOutputLanguages() {
    final List<DropdownMenuEntry<String>> res = [];
    _availableLanguages.forEach((key, value) {
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
    try {
      _offlineController.removeListener(_onOfflineChanged);
      _offlineController.dispose();
    } catch (_) {}
    super.dispose();
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
