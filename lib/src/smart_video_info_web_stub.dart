import 'dart:async';
import 'smart_video_info_model.dart';
import 'smart_video_info_plugin.dart';

/// Stub implementation for non-web platforms
class SmartVideoInfoWeb {
  /// Registers this class (no-op for non-web platforms)
  static void registerWith(dynamic registrar) {
    throw UnsupportedError('Web platform is not supported on this platform');
  }

  /// Not supported on non-web platforms
  static Future<SmartVideoInfo> getInfo(String path) {
    throw UnsupportedError('Web platform is not supported on this platform');
  }

  /// Not supported on non-web platforms
  static Future<List<SmartVideoInfo>> getBatch(List<String> paths) {
    throw UnsupportedError('Web platform is not supported on this platform');
  }

  /// Not supported on non-web platforms
  static Future<bool> isSupported(String path) {
    throw UnsupportedError('Web platform is not supported on this platform');
  }
}
