import 'dart:async';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

import 'smart_video_info_model.dart';
import 'smart_video_info_plugin.dart';

/// Web implementation of SmartVideoInfoPlugin
class SmartVideoInfoWeb {
  /// Registers this class as the default instance of [SmartVideoInfoPlugin].
  static void registerWith(dynamic registrar) {
    // No-op for web platform - plugin is accessed directly via conditional imports
  }

  /// Extracts metadata from a video file using HTML5 Video API via JavaScript
  static Future<SmartVideoInfo> getInfo(String path) async {
    final completer = Completer<SmartVideoInfo>();
    
    try {
      // Use JavaScript implementation for better browser compatibility
      final jsInstance = js.JsObject(js.context['SmartVideoInfoWeb'] as js.JsFunction);
      final jsPromise = jsInstance.callMethod('getInfo', [path]) as js.JsObject;
      
      // Convert JS Promise to Dart Future manually
      jsPromise.callMethod('then', [
        (result) {
          try {
            final jsResult = result as js.JsObject;
            final success = jsResult['success'] as bool;
            
            if (success) {
              final data = jsResult['data'] as js.JsObject;
              final info = _parseMetadataFromJs(data);
              completer.complete(info);
            } else {
              final error = jsResult['error'] as String?;
              completer.completeError(
                SmartVideoInfoException(error ?? 'Unknown error'),
              );
            }
          } catch (e) {
            completer.completeError(
              SmartVideoInfoException('Failed to parse metadata: $e'),
            );
          }
        }
      ]);
      
      jsPromise.callMethod('catch', [
        (error) {
          try {
            final jsError = error as js.JsObject;
            final errorMsg = jsError['error'] as String?;
            completer.completeError(
              SmartVideoInfoException(errorMsg ?? 'Failed to load video'),
            );
          } catch (e) {
            completer.completeError(
              SmartVideoInfoException('Failed to load video: $e'),
            );
          }
        }
      ]);
    } catch (e) {
      completer.completeError(
        SmartVideoInfoException('Error calling JavaScript: $e'),
      );
    }

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw SmartVideoInfoException('Metadata extraction timed out', 'TIMEOUT');
      },
    );
  }

  /// Extracts metadata from multiple video files
  static Future<List<SmartVideoInfo>> getBatch(List<String> paths) async {
    final results = <SmartVideoInfo>[];
    
    for (final path in paths) {
      try {
        final info = await getInfo(path);
        results.add(info);
      } catch (e) {
        throw SmartVideoInfoException('Batch processing failed: $e');
      }
    }
    
    return results;
  }

  /// Checks if a video file is supported
  static Future<bool> isSupported(String path) async {
    try {
      final info = await getInfo(path);
      return info.width > 0 && info.height > 0;
    } catch (_) {
      return false;
    }
  }

  /// Parses metadata from JavaScript object
  static SmartVideoInfo _parseMetadataFromJs(js.JsObject data) {
    final width = data['width'] as int;
    final height = data['height'] as int;
    final duration = data['duration'] as int;
    final codec = data['codec'] as String;
    final bitrate = data['bitrate'] as int;
    final fps = (data['fps'] as num).toDouble();
    final rotation = data['rotation'] as int;
    final container = data['container'] as String;
    final hasAudio = data['hasAudio'] as bool;
    final hasSubtitles = data['hasSubtitles'] as bool;
    final streamCount = data['streamCount'] as int;

    String? audioCodec;
    int? sampleRate;
    int? channels;

    if (hasAudio) {
      audioCodec = data['audioCodec'] as String?;
      sampleRate = data['sampleRate'] as int?;
      channels = data['channels'] as int?;
    }

    return SmartVideoInfo(
      width: width,
      height: height,
      duration: Duration(milliseconds: duration),
      codec: codec,
      bitrate: bitrate,
      fps: fps,
      rotation: rotation,
      container: container,
      audioCodec: audioCodec,
      sampleRate: sampleRate,
      channels: channels,
      hasAudio: hasAudio,
      hasSubtitles: hasSubtitles,
      streamCount: streamCount,
    );
  }
}
