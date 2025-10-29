import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class OfflineCheckController extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<dynamic> _connectivitySubscription;

  bool isOffline = false;

  OfflineCheckController() {
    // Listen to connectivity changes. Some plugin versions emit a single
    // ConnectivityResult, others emit List<ConnectivityResult>.
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      dynamic result,
    ) async {
      // Normalize and resolve the connectivity result, then update state.
      ConnectivityResult resolved = ConnectivityResult.none;
      if (result is List && result.isNotEmpty) {
        resolved = result.first;
      } else if (result is ConnectivityResult) {
        resolved = result;
      } else {
        // fallback to an explicit check if unexpected value received
        resolved = await resolveConnectivity();
      }

      final bool nowOffline = resolved == ConnectivityResult.none;
      if (nowOffline != isOffline) {
        isOffline = nowOffline;
        notifyListeners();
      }
    });

    // Perform an initial connectivity check so consumers have a starting value.
    () async {
      final ConnectivityResult initial = await resolveConnectivity();
      final bool nowOffline = initial == ConnectivityResult.none;
      if (nowOffline != isOffline) {
        isOffline = nowOffline;
        notifyListeners();
      }
    }();
  }

  /// Resolve current connectivity into a [ConnectivityResult]. Normalizes
  /// plugin results which may return a single [ConnectivityResult] or a
  /// [List<ConnectivityResult>]. If [connectivityResult] is provided it is
  /// returned directly.
  Future<ConnectivityResult> resolveConnectivity({
    ConnectivityResult? connectivityResult,
  }) async {
    if (connectivityResult != null) return connectivityResult;

    final dynamic check = await _connectivity.checkConnectivity();
    if (check is List && check.isNotEmpty) {
      return check.first as ConnectivityResult;
    } else if (check is ConnectivityResult) {
      return check;
    } else {
      return ConnectivityResult.none;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
