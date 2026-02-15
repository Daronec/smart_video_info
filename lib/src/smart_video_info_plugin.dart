import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'smart_video_info_model.dart';

/// Exception thrown when metadata extraction fails.
class SmartVideoInfoException implements Exception {
  final String message;
  final String? code;

  SmartVideoInfoException(this.message, [this.code]);

  @override
  String toString() => 'SmartVideoInfoException: $message';
}

/// Ultra-fast video metadata extraction powered by Smart FFmpeg Engine.
///
/// Example:
/// ```dart
/// final info = await SmartVideoInfoPlugin.getInfo('/path/to/video.mp4');
/// print('Resolution: ${info.resolution}');
/// print('Duration: ${info.duration}');
/// ```
class SmartVideoInfoPlugin {
  static const MethodChannel _channel = MethodChannel('smart_video_info');

  /// Extracts metadata from a single video file.
  ///
  /// [path] must be an absolute path to an existing video file.
  ///
  /// Throws [SmartVideoInfoException] if extraction fails.
  /// Throws [TimeoutException] if operation exceeds [timeout].
  static const Duration defaultTimeout = Duration(seconds: 10);

  static Future<SmartVideoInfo> getInfo(
    String path, {
    Duration timeout = defaultTimeout,
  }) async {
    try {
      final jsonString = await _channel
          .invokeMethod<String>('getInfo', {'path': path}).timeout(timeout);

      if (jsonString == null) {
        throw SmartVideoInfoException('No response from native layer');
      }

      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

      if (decoded['success'] != true) {
        throw SmartVideoInfoException(
          decoded['error']?.toString() ?? 'Metadata extraction failed',
        );
      }

      return SmartVideoInfo.fromJson(decoded['data'] as Map<String, dynamic>);
    } on TimeoutException {
      throw SmartVideoInfoException('Operation timed out', 'TIMEOUT');
    } on PlatformException catch (e) {
      throw SmartVideoInfoException(e.message ?? 'Platform error', e.code);
    }
  }

  /// Extracts metadata from multiple video files efficiently.
  ///
  /// This is more efficient than calling [getInfo] multiple times
  /// as it processes all files in a single native call.
  ///
  /// Returns a list of [SmartVideoInfo] in the same order as input [paths].
  /// If extraction fails for a specific file, throws [SmartVideoInfoException].
  static Future<List<SmartVideoInfo>> getBatch(
    List<String> paths, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (paths.isEmpty) {
      return [];
    }

    try {
      final results = await _channel.invokeMethod<List<dynamic>>(
          'getBatch', {'paths': paths}).timeout(timeout);

      if (results == null) {
        throw SmartVideoInfoException('No response from native layer');
      }

      return results.map((jsonString) {
        final decoded =
            jsonDecode(jsonString as String) as Map<String, dynamic>;

        if (decoded['success'] != true) {
          throw SmartVideoInfoException(
            decoded['error']?.toString() ?? 'Metadata extraction failed',
          );
        }

        return SmartVideoInfo.fromJson(decoded['data'] as Map<String, dynamic>);
      }).toList();
    } on TimeoutException {
      throw SmartVideoInfoException('Operation timed out', 'TIMEOUT');
    } on PlatformException catch (e) {
      throw SmartVideoInfoException(e.message ?? 'Platform error', e.code);
    }
  }

  /// Checks if the file at [path] is a supported video format.
  ///
  /// Returns `true` if metadata can be extracted, `false` otherwise.
  /// This is a convenience method that catches all exceptions.
  static Future<bool> isSupported(String path) async {
    try {
      final info = await getInfo(path);
      return info.width > 0 && info.height > 0;
    } catch (_) {
      return false;
    }
  }
}
