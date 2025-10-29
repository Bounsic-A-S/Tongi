import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/ui/core/tongi_colors.dart';
import 'package:frontend/ui/core/tongi_languages.dart';
import 'package:frontend/logic/controllers/model_manager_controller.dart';
import 'package:frontend/ui/widgets/settings/lang_download_card.dart';
import 'package:frontend/ui/widgets/settings/lang_model_card.dart';

class SettingsModelsScreen extends StatefulWidget {
  const SettingsModelsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsModelsScreenState();
}

class _SettingsModelsScreenState extends State<SettingsModelsScreen> {
  final _modelManager = OnDeviceTranslatorModelManager();
  late List<String>? _downloadedKeys = null;
  late List<String>? _availableKeys = null;
  List<String> _filteredAvailableKeys = [];

  @override
  void initState() {
    _loadModels();
    super.initState();
  }

  void _loadModels() async {
    Map<String, String> mod;
    mod = await _modelManager.getDownloadedLanguages();
    _downloadedKeys = mod.keys.toList();
    mod = await _modelManager.getAvailableLanguages();
    _availableKeys = mod.keys.toList();
    _filteredAvailableKeys = _availableKeys!;
    _safeSetState();
  }

  void _filterAvailableKeys(String query) {
    query = query.toLowerCase();
    _filteredAvailableKeys = _availableKeys!
        .where((v) => localLanguages[v]!.toLowerCase().contains(query))
        .toList();
    _safeSetState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modelos sin conexión'),
        backgroundColor: TongiColors.primary,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: ListView(
          children: [
            // Modelos disponibles para descargar --------
            const Row(
              children: [
                Icon(Icons.wifi, color: TongiColors.primary, size: 28),
                SizedBox(width: 10),
                Text(
                  "Lenguajes disponibles",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                // fillColor: Colors.,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
              onChanged: _filterAvailableKeys,
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 305,
              child: (_availableKeys != null)
                  ? ListView.builder(
                      itemCount: _filteredAvailableKeys.length,
                      itemBuilder: (context, index) {
                        final String langName =
                            localLanguages[_filteredAvailableKeys[index]]!;
                        return LangDownloadCard(
                          code: _filteredAvailableKeys[index],
                          name: langName,
                          onTap: _downloadTargetModel,
                          callback: _update,
                        );
                      },
                    )
                  : Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      ),
                    ),
            ),
            SizedBox(height: 40),

            // Modelos descargados localmente --------
            const Row(
              children: [
                Icon(
                  Icons.download_rounded,
                  color: TongiColors.primary,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  "Modelos descargados:",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 305,
              child: (_downloadedKeys != null)
                  ? (_downloadedKeys!.isNotEmpty)
                        ? ListView.builder(
                            itemCount: _downloadedKeys!.length,
                            itemBuilder: (context, index) {
                              final String langName =
                                  localLanguages[_downloadedKeys![index]]!;
                              return LangModelCard(
                                code: _downloadedKeys![index],
                                name: langName,
                                onDelete: _deleteSourceModel,
                                callback: _update,
                              );
                            },
                          )
                        : Text("No hay modelos de lenguaje descargados")
                  : Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _update() {
    _loadModels();
    _safeSetState();
  }

  Future<bool> _downloadTargetModel(String code) async {
    try {
      return await _modelManager.downloadModel(code);
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteSourceModel(String code) async {
    try {
      return await _modelManager.deleteModel(code);
    } catch (e) {
      return false;
    }
  }

  void _safeSetState() {
    if (mounted) {
      setState(() {});
    }
  }
}
