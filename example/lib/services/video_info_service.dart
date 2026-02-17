import 'package:flutter/foundation.dart';
import 'package:smart_video_info/smart_video_info.dart';

/// Результат извлечения метаданных видео.
class VideoInfoResult {
  final SmartVideoInfo info;
  final int extractionTimeMs;

  const VideoInfoResult({
    required this.info,
    required this.extractionTimeMs,
  });
}

/// Сервис для получения метаданных видео.
class VideoInfoService {
  /// Извлекает метаданные видео файла.
  /// 
  /// Возвращает [VideoInfoResult] с информацией и временем извлечения.
  /// Выбрасывает [SmartVideoInfoException] при ошибке.
  Future<VideoInfoResult> getVideoInfo(String path) async {
    final stopwatch = Stopwatch()..start();

    try {
      debugPrint('Getting video info for: $path');
      final info = await SmartVideoInfoPlugin.getInfo(path);
      stopwatch.stop();

      _logVideoInfo(info, stopwatch.elapsedMilliseconds);

      return VideoInfoResult(
        info: info,
        extractionTimeMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      debugPrint('Error getting video info: $e');
      rethrow;
    }
  }

  /// Логирует информацию о видео в консоль.
  void _logVideoInfo(SmartVideoInfo info, int timeMs) {
    debugPrint('Successfully extracted metadata in ${timeMs}ms');
    debugPrint('Video dimensions: ${info.width}x${info.height}');
    debugPrint('Duration: ${info.duration.inMilliseconds}ms');
    debugPrint('Has audio: ${info.hasAudio}');
    
    if (info.hasAudio) {
      debugPrint('Audio codec: ${info.audioCodec}');
      debugPrint('Sample rate: ${info.sampleRate}');
      debugPrint('Channels: ${info.channels}');
    }
    
    debugPrint('Stream count: ${info.streamCount}');
  }
}
