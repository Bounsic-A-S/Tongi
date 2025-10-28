import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/ui/core/tongi_languages.dart';
import 'package:frontend/logic/controllers/model_manager_controller.dart';

class OfflineCheckController extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<dynamic> _connectivitySubscription;

  /// Currently available languages depending on connectivity / downloaded models
  List<MapEntry<String, String>> availableLanguages = tongiLanguages.entries
      .toList();
  bool loading = false;
  bool isOffline = false;

  OfflineCheckController() {
    // Listen to connectivity changes. Some plugin versions emit a single
    // ConnectivityResult, others emit List<ConnectivityResult>.
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      dynamic result,
    ) {
      ConnectivityResult resolved;
      if (result is List && result.isNotEmpty) {
        resolved = result.first;
      } else if (result is ConnectivityResult) {
        resolved = result;
      } else {
        resolved = ConnectivityResult.none;
      }
      _loadDownloadedLanguages(connectivityResult: resolved);
    });

    // Initial load
    _loadDownloadedLanguages();
  }

  Future<void> _loadDownloadedLanguages({
    ConnectivityResult? connectivityResult,
  }) async {
    loading = true;
    notifyListeners();

    ConnectivityResult result;
    if (connectivityResult != null) {
      result = connectivityResult;
    } else {
      final dynamic check = await _connectivity.checkConnectivity();
      if (check is List && check.isNotEmpty) {
        result = check.first as ConnectivityResult;
      } else if (check is ConnectivityResult) {
        result = check;
      } else {
        result = ConnectivityResult.none;
      }
    }

    final RegExp validModelRegex = RegExp(r'^[a-z]{2,3}(?:_[a-z]{2,3})?$');

    isOffline = result == ConnectivityResult.none;
    final bool isOfflineLocal = isOffline;

    if (isOfflineLocal) {
      final modelManager = OnDeviceTranslatorModelManager();
      // Check downloaded models in parallel to avoid blocking the UI while
      // querying each model serially. If a check fails, treat as not
      // downloaded.
      final futures = tongiLanguages.entries.map((entry) async {
        // Normalize key to lower-case for validation
        final code = entry.key.toLowerCase();
        if (!validModelRegex.hasMatch(code)) {
          // skip codes that don't match ML Kit expected pattern (e.g. zh-Hans)
          return MapEntry(entry, false);
        }
        try {
          final isDownloaded = await modelManager.isModelDownloaded(code);
          return MapEntry(entry, isDownloaded);
        } catch (_) {
          return MapEntry(entry, false);
        }
      }).toList();

      final results = await Future.wait(futures);
      availableLanguages = results
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
    } else {
      availableLanguages = tongiLanguages.entries.toList();
    }

    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
