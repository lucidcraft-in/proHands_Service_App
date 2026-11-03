import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _periodicTimer;

  bool _isConnected = true;
  bool _isReconnected = false;
  bool _isChecking = false;

  bool get isConnected => _isConnected;
  bool get isReconnected => _isReconnected;
  bool get isChecking => _isChecking;

  ConnectivityProvider() {
    _initConnectivity();
  }

  void _initConnectivity() {
    // Initial check
    checkConnection();

    // Listen to OS network interface changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });

    // Periodic lightweight ping every 15s to detect silent internet loss/restoration
    _periodicTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      checkConnection(isBackground: true);
    });
  }

  Future<void> _handleConnectivityChange(List<ConnectivityResult> results) async {
    final hasInterface = results.any((r) => r != ConnectivityResult.none);
    if (!hasInterface) {
      _setOffline();
      return;
    }
    // Has network interface (WiFi / Cellular); test actual internet reachability
    await checkConnection();
  }

  Future<bool> _hasActualInternet() async {
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } catch (_) {
      try {
        final backup = await InternetAddress.lookup('one.one.one.one')
            .timeout(const Duration(seconds: 3));
        return backup.isNotEmpty && backup[0].rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }

  Future<void> checkConnection({bool isBackground = false}) async {
    if (_isChecking) return;
    if (!isBackground) {
      _isChecking = true;
      notifyListeners();
    }

    try {
      final results = await _connectivity.checkConnectivity();
      final hasInterface = results.any((r) => r != ConnectivityResult.none);

      if (!hasInterface) {
        _setOffline();
      } else {
        final hasInternet = await _hasActualInternet();
        if (hasInternet) {
          _setOnline();
        } else {
          _setOffline();
        }
      }
    } catch (_) {
      _setOffline();
    } finally {
      if (!isBackground) {
        _isChecking = false;
        notifyListeners();
      }
    }
  }

  void _setOffline() {
    if (_isConnected) {
      _isConnected = false;
      _isReconnected = false;
      notifyListeners();
    }
  }

  void _setOnline() {
    if (!_isConnected) {
      _isConnected = true;
      _isReconnected = true;
      notifyListeners();

      // Automatically dismiss the "Back Online" banner after 2.5 seconds
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (_isConnected) {
          _isReconnected = false;
          notifyListeners();
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _periodicTimer?.cancel();
    super.dispose();
  }
}

