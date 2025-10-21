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

    final bool isOffline = result == ConnectivityResult.none;

    if (isOffline) {
      final modelManager = OnDeviceTranslatorModelManager();
      List<MapEntry<String, String>> downloaded = [];
      for (var entry in tongiLanguages.entries) {
        bool isDownloaded = false;
        try {
          isDownloaded = await modelManager.isModelDownloaded(entry.value);
        } catch (_) {}
        if (isDownloaded) downloaded.add(entry);
      }
      availableLanguages = downloaded;
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
