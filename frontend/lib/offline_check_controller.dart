import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:frontend/core/tongi_languages.dart';
import 'package:frontend/services/model_manager_service.dart';

class OfflineCheckController {
  late final Connectivity _connectivity;
  late final Stream<List<ConnectivityResult>> _connectivityStream;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  OfflineCheckController() {
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivitySubscription = _connectivityStream.listen((results) {
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      _loadDownloadedLanguages(connectivityResult: result);
    });
    _loadDownloadedLanguages();
  }

  Future<void> _loadDownloadedLanguages({
    ConnectivityResult? connectivityResult,
  }) async {
    ConnectivityResult result;
    if (connectivityResult != null) {
      result = connectivityResult;
    } else {
      result = (await _connectivity.checkConnectivity()) as ConnectivityResult;
    }
    bool isOffline = result == ConnectivityResult.none;

    // setState(() {
    //   _loading = true;
    // });

    if (isOffline) {
      final modelManager = OnDeviceTranslatorModelManager();
      List<MapEntry<String, String>> downloaded = [];
      for (var entry in completeLanguages.entries) {
        bool isDownloaded = false;
        try {
          isDownloaded = await modelManager.isModelDownloaded(entry.value);
        } catch (_) {}
        if (isDownloaded) downloaded.add(entry);
      }
      // setState(() {
      //   _availableLanguages = downloaded;
      //   _loading = false;
      // });
    } else {
      // setState(() {
      //   _availableLanguages = completeLanguages.entries.toList();
      //   _loading = false;
      // });
    }
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
