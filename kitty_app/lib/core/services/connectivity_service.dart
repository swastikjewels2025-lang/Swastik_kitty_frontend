import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service monitoring network connectivity state across WiFi, Cellular, and offline modes.
class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Check current online status.
  Future<bool> isConnected() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }

  /// Broadcast stream emitting `true` when online and `false` when disconnected.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_isOnline);
  }

  static bool _isOnline(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any(
      (ConnectivityResult result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn,
    );
  }
}
