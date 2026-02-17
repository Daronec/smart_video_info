import 'package:flutter/material.dart';
import 'package:smart_video_info/smart_video_info.dart';
import '../constants/app_constants.dart';
import '../utils/formatters.dart';
import 'info_row.dart';

/// Карточка с информацией о производительности извлечения метаданных.
/// 
/// Отображает время, затраченное на извлечение метаданных видео.
class PerformanceCard extends StatelessWidget {
  final int extractionTimeMs;

  const PerformanceCard({
    super.key,
    required this.extractionTimeMs,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingCard),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.speed),
            const SizedBox(width: AppConstants.spacingMedium),
            Text(
              '${AppConstants.extractionTimePrefix}$extractionTimeMs${AppConstants.millisecondsSuffix}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Карточка с путем к выбранному видео файлу.
/// 
/// Отображает имя файла, извлеченное из полного пути.
class FilePathCard extends StatelessWidget {
  final String path;

  const FilePathCard({
    super.key,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingCardSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.labelFile,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              path.split('/').last,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Карточка с основными свойствами видео.
/// 
/// Отображает разрешение, длительность, кодек, FPS, битрейт,
/// поворот, контейнер и ориентацию видео.
class VideoPropertiesCard extends StatelessWidget {
  final SmartVideoInfo videoInfo;

  const VideoPropertiesCard({
    super.key,
    required this.videoInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.labelVideo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            InfoRow(
              icon: Icons.aspect_ratio,
              label: AppConstants.labelResolution,
              value: videoInfo.resolution,
            ),
            InfoRow(
              icon: Icons.timer,
              label: AppConstants.labelDuration,
              value: Formatters.formatDuration(videoInfo.duration),
            ),
            InfoRow(
              icon: Icons.movie,
              label: AppConstants.labelCodec,
              value: videoInfo.codec,
            ),
            InfoRow(
              icon: Icons.speed,
              label: AppConstants.labelFps,
              value: videoInfo.fps.toStringAsFixed(AppConstants.fpsFractionDigits),
            ),
            InfoRow(
              icon: Icons.data_usage,
              label: AppConstants.labelBitrate,
              value: Formatters.formatBitrate(videoInfo.bitrate),
            ),
            InfoRow(
              icon: Icons.rotate_right,
              label: AppConstants.labelRotation,
              value: '${videoInfo.rotation}${AppConstants.unitDegrees}',
            ),
            InfoRow(
              icon: Icons.folder,
              label: AppConstants.labelContainer,
              value: videoInfo.container,
            ),
            InfoRow(
              icon: Icons.crop_landscape,
              label: AppConstants.labelOrientation,
              value: videoInfo.isPortrait 
                  ? AppConstants.valuePortrait 
                  : AppConstants.valueLandscape,
            ),
          ],
        ),
      ),
    );
  }
}

/// Карточка с аудио свойствами видео файла.
/// 
/// Отображает наличие аудио, кодек, частоту дискретизации
/// и количество каналов (если аудио присутствует).
class AudioPropertiesCard extends StatelessWidget {
  final SmartVideoInfo videoInfo;

  const AudioPropertiesCard({
    super.key,
    required this.videoInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.labelAudio,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            InfoRow(
              icon: videoInfo.hasAudio ? Icons.volume_up : Icons.volume_off,
              label: AppConstants.labelHasAudio,
              value: videoInfo.hasAudio 
                  ? AppConstants.valueYes 
                  : AppConstants.valueNo,
            ),
            if (videoInfo.audioCodec != null)
              InfoRow(
                icon: Icons.audiotrack,
                label: AppConstants.labelAudioCodec,
                value: videoInfo.audioCodec!,
              ),
            if (videoInfo.sampleRate != null)
              InfoRow(
                icon: Icons.graphic_eq,
                label: AppConstants.labelSampleRate,
                value: '${videoInfo.sampleRate}${AppConstants.unitHz}',
              ),
            if (videoInfo.channels != null)
              InfoRow(
                icon: Icons.surround_sound,
                label: AppConstants.labelChannels,
                value: videoInfo.channels == AppConstants.stereoChannels
                    ? AppConstants.valueStereo
                    : '${videoInfo.channels}',
              ),
          ],
        ),
      ),
    );
  }
}

/// Карточка с дополнительными свойствами видео файла.
/// 
/// Отображает информацию о субтитрах и количестве потоков.
class OtherPropertiesCard extends StatelessWidget {
  final SmartVideoInfo videoInfo;

  const OtherPropertiesCard({
    super.key,
    required this.videoInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.labelOther,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            InfoRow(
              icon: Icons.subtitles,
              label: AppConstants.labelSubtitles,
              value: videoInfo.hasSubtitles 
                  ? AppConstants.valueYes 
                  : AppConstants.valueNo,
            ),
            InfoRow(
              icon: Icons.stream,
              label: AppConstants.labelStreamCount,
              value: '${videoInfo.streamCount}',
            ),
          ],
        ),
      ),
    );
  }
}
