import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static bool _isOnline = true;

  static bool get isOnline => _isOnline;

  static Future<void> init() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
  }

  static Stream<bool> getConnectivityStream() {
    return _connectivity.onConnectivityChanged.map((result) {
      _isOnline = result != ConnectivityResult.none;
      return _isOnline;
    });
  }
}
