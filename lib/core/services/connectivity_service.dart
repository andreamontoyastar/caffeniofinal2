import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Servicio que monitorea el estado de la conectividad de red.
///
/// Expone [isConnected] reactivo: la UI puede escuchar cambios
/// y mostrar banners offline en tiempo real.
class ConnectivityService extends ChangeNotifier {
  ConnectivityService() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  List<ConnectivityResult> _results = [ConnectivityResult.none];
  bool _isInitialized = false;

  // ── Getters ───────────────────────────────────────────────────────────────

  /// true si hay al menos un tipo de conexión activa.
  bool get isConnected =>
      _results.any((r) => r != ConnectivityResult.none);

  bool get isWifi => _results.contains(ConnectivityResult.wifi);
  bool get isMobile => _results.contains(ConnectivityResult.mobile);
  bool get isEthernet => _results.contains(ConnectivityResult.ethernet);

  /// true cuando se realizó la primera verificación.
  bool get isInitialized => _isInitialized;

  List<ConnectivityResult> get results => List.unmodifiable(_results);

  // ── Inicialización ────────────────────────────────────────────────────────

  void _init() {
    // Estado inicial (asíncrono)
    _connectivity.checkConnectivity().then((results) {
      _results = results;
      _isInitialized = true;
      notifyListeners();
    });

    // Escuchar cambios continuos
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        _results = results;
        notifyListeners();
      },
      onError: (_) {
        // En caso de error, asumir sin conexión
        _results = [ConnectivityResult.none];
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
