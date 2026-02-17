import '../constants/app_constants.dart';

/// Утилиты для форматирования данных.
class Formatters {
  // Приватный конструктор для предотвращения создания экземпляров
  Formatters._();

  /// Форматирует длительность видео в читаемый формат (HH:MM:SS или MM:SS).
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Форматирует битрейт в читаемый формат (Mbps, Kbps или bps).
  static String formatBitrate(int bitrate) {
    if (bitrate >= AppConstants.bitrateThresholdMbps) {
      final mbps = (bitrate / AppConstants.bitrateThresholdMbps)
          .toStringAsFixed(AppConstants.mbpsFractionDigits);
      return '$mbps${AppConstants.unitMbps}';
    } else if (bitrate >= AppConstants.bitrateThresholdKbps) {
      final kbps = (bitrate / AppConstants.bitrateThresholdKbps)
          .toStringAsFixed(AppConstants.kbpsFractionDigits);
      return '$kbps${AppConstants.unitKbps}';
    }
    return '$bitrate${AppConstants.unitBps}';
  }
}
