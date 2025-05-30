import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class InternetConnectionService {
  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<bool> isConnected = ValueNotifier(true);

  InternetConnectionService() {
    _verifyInitialConnection();
    _listenToConnectionChanges();
  }

  void _verifyInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    final connection = result.any((r) => r != ConnectivityResult.none);
    isConnected.value = connection;
  }

  void _listenToConnectionChanges() {
    _connectivity.onConnectivityChanged.listen((results) {
      final connected = results.any((r) => r != ConnectivityResult.none);
      if (connected != isConnected.value) {
        isConnected.value = connected;
      }
    });
  }

  void dispose() {
    isConnected.dispose();
  }
}
