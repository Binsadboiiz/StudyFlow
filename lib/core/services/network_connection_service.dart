import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service quản lý trạng thái kết nối internet của người dùng.
/// Cung cấp stream thay đổi trạng thái và phương thức kiểm tra tức thời.
class NetworkConnectionService with ChangeNotifier {
  bool _isOnline = true;

  /// Trạng thái kết nối hiện tại (true: online, false: offline)
  bool get isOnline => _isOnline;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkConnectionService() {
    _init();
  }

  Future<void> _init() async {
    // Kiểm tra trạng thái lúc khởi động
    final results = await _connectivity.checkConnectivity();
    await _updateConnectionStatus(results);

    // Lắng nghe sự thay đổi kết nối từ thiết bị
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      await _updateConnectionStatus(results);
    });
  }

  /// Cập nhật trạng thái và thực hiện kiểm tra internet thực tế (ping google)
  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _isOnline = false;
    } else {
      // Có kết nối mạng vật lý (Wifi/Cellular), kiểm tra xem có internet thực sự không
      _isOnline = await checkRealInternetAccess();
    }
    notifyListeners();
  }

  /// Ping thử tới Google để kiểm tra xem thiết bị có thực sự vào được internet hay không
  Future<bool> checkRealInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 4),
      );
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Cưỡng bức kiểm tra lại trạng thái kết nối
  Future<bool> forceCheck() async {
    final results = await _connectivity.checkConnectivity();
    await _updateConnectionStatus(results);
    return _isOnline;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
