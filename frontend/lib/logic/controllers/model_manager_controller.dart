import 'dart:async';

import 'package:flutter/services.dart';
import 'package:frontend/ui/core/tongi_languages.dart';

/// A class to manage remote models.
class ModelManager {
  /// The method name to be called.
  final String method;

  /// The channel used to manage the remote model.
  final MethodChannel channel;

  /// Constructor to create an instance of [ModelManager].
  ModelManager({required this.channel, required this.method});

  /// Checks whether a model is downloaded or not.
  Future<bool> isModelDownloaded(String model) async {
    final result = await channel.invokeMethod(method, <String, dynamic>{
      'task': 'check',
      'model': model,
    });
    return result as bool;
  }

  /// Downloads a model.
  /// Returns true if model downloads successfully or model is already downloaded.
  /// On failing to download it throws an error.
  Future<bool> downloadModel(String model, {bool isWifiRequired = true}) async {
    final result = await channel.invokeMethod(method, <String, dynamic>{
      'task': 'download',
      'model': model,
      'wifi': isWifiRequired,
    });
    return result.toString() == 'success';
  }

  /// Deletes a model.
  /// Returns true if model is deleted successfully or model is not present.
  Future<bool> deleteModel(String model) async {
    final result = await channel.invokeMethod(method, <String, dynamic>{
      'task': 'delete',
      'model': model,
    });
    return result.toString() == 'success';
  }

  /// Check which language models are downloaded locally and return a
  /// mapping from model code (lower-cased) to its display label.
  ///
  /// Uses `localLanguages` keys (language codes) and queries
  /// [isModelDownloaded] in parallel. Failures are treated as "not
  /// downloaded".
  Future<Map<String, String>> getDownloadedLanguages() async {
    final entries = localLanguages.entries
        .map((e) => MapEntry(e.key.toLowerCase(), e.value))
        .toList();

    final futures = entries.map((entry) async {
      try {
        final downloaded = await isModelDownloaded(entry.key);
        return downloaded ? entry : null;
      } catch (_) {
        return null;
      }
    }).toList();

    final results = await Future.wait(futures);
    final Map<String, String> downloaded = {};
    for (final e in results.whereType<MapEntry<String, String>>()) {
      downloaded[e.key] = e.value;
    }
    return downloaded;
  }

  Future<Map<String, String>> getAvailableLanguages() async {
    final entries = localLanguages.entries
        .map((e) => MapEntry(e.key.toLowerCase(), e.value))
        .toList();

    final futures = entries.map((entry) async {
      try {
        final downloaded = await isModelDownloaded(entry.key);
        return !downloaded ? entry : null;
      } catch (_) {
        return null;
      }
    }).toList();

    final results = await Future.wait(futures);
    final Map<String, String> downloaded = {};
    for (final e in results.whereType<MapEntry<String, String>>()) {
      downloaded[e.key] = e.value;
    }
    return downloaded;
  }
}

class OnDeviceTranslatorModelManager extends ModelManager {
  /// Constructor to create an instance of [OnDeviceTranslatorModelManager].
  OnDeviceTranslatorModelManager()
    : super(
        channel: MethodChannel('google_mlkit_on_device_translator'),
        method: 'nlp#manageLanguageModelModels',
      );
}
