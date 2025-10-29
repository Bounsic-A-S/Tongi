import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/ui/core/tongi_colors.dart';
import 'package:frontend/ui/core/tongi_languages.dart';
import 'package:frontend/logic/controllers/model_manager_controller.dart';
import 'package:frontend/widgets/transition/loading_indicator.dart';

class SettingsModelsScreen extends StatefulWidget {
  const SettingsModelsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsModelsScreenState();
}

class _SettingsModelsScreenState extends State<SettingsModelsScreen> {
  final _modelManager = OnDeviceTranslatorModelManager();

  var _pickedLanguage = "en";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Modelos sin conexión')),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [const SizedBox(width: 50), _buildDropdown(false)],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _downloadTargetModel,
                    child: const Text('Descargar modelo'),
                  ),
                  ElevatedButton(
                    onPressed: _deleteSourceModel,
                    child: const Text('Eliminar modelo'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(bool isTarget) => DropdownButton<String>(
    value: _pickedLanguage,
    icon: const Icon(Icons.arrow_downward),
    elevation: 16,
    style: const TextStyle(color: Colors.blue),
    underline: Container(height: 2, color: Colors.blue),
    onChanged: (value) {
      setState(() {
        _pickedLanguage = value!;
      });
    },
    items: localLanguages.entries.map<DropdownMenuItem<String>>((entry) {
      // localLanguages now maps code -> label, so value should be the
      // language code (entry.key) and the visible label the entry.value.
      return DropdownMenuItem<String>(
        value: entry.key,
        child: Text(entry.value),
      );
    }).toList(),
  );

  Future<void> _downloadTargetModel() async {
    Toast().show(
      'Downloading model ($_pickedLanguage)...',
      _modelManager
          .downloadModel(_pickedLanguage)
          .then((value) => value ? 'success' : 'failed'),
      context,
      this,
    );
  }

  Future<void> _deleteSourceModel() async {
    Toast().show(
      'Deleting model ($_pickedLanguage)...',
      _modelManager
          .deleteModel(_pickedLanguage)
          .then((value) => value ? 'success' : 'failed'),
      context,
      this,
    );
  }
}
