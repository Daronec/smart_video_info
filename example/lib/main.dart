import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smart_video_info/smart_video_info.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html show Url, Blob;
// ignore: unused_import
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Video Info Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VideoInfoPage(),
    );
  }
}

class VideoInfoPage extends StatefulWidget {
  const VideoInfoPage({super.key});

  @override
  State<VideoInfoPage> createState() => _VideoInfoPageState();
}

class _VideoInfoPageState extends State<VideoInfoPage> {
  SmartVideoInfo? _videoInfo;
  String? _selectedPath;
  bool _isLoading = false;
  String? _error;
  int? _extractionTimeMs;

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // On web, use bytes to create blob URL
        if (kIsWeb) {
          final bytes = file.bytes;
          if (bytes != null) {
            // Create blob URL from bytes with proper MIME type
            final mimeType = _getMimeType(file.name);
            debugPrint('File: ${file.name}, MIME type: $mimeType');
            final blob = html.Blob([bytes], mimeType);
            final url = html.Url.createObjectUrlFromBlob(blob);
            debugPrint('Created blob URL: $url');
            await _getVideoInfo(url);
          } else {
            setState(() {
              _error = 'Failed to read file bytes on web platform';
            });
          }
        } else {
          // On native platforms, use path
          final path = file.path;
          if (path != null) {
            await _getVideoInfo(path);
          } else {
            setState(() {
              _error = 'Failed to get file path';
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      setState(() {
        _error = 'Error picking file: $e';
      });
    }
  }

  String _getMimeType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'mp4':
      case 'm4v':
        return 'video/mp4';
      case 'webm':
        return 'video/webm';
      case 'ogv':
      case 'ogg':
        return 'video/ogg';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      case 'flv':
        return 'video/x-flv';
      case '3gp':
        return 'video/3gpp';
      case 'wmv':
        return 'video/x-ms-wmv';
      default:
        return 'video/mp4'; // Default fallback
    }
  }

  Future<void> _getVideoInfo(String path) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedPath = path;
      _videoInfo = null;
      _extractionTimeMs = null;
    });

    final stopwatch = Stopwatch()..start();

    try {
      debugPrint('Getting video info for: $path');
      final info = await SmartVideoInfoPlugin.getInfo(path);
      stopwatch.stop();

      debugPrint('Successfully extracted metadata in ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('Video dimensions: ${info.width}x${info.height}');
      debugPrint('Duration: ${info.duration.inMilliseconds}ms');
      debugPrint('Has audio: ${info.hasAudio}');
      if (info.hasAudio) {
        debugPrint('Audio codec: ${info.audioCodec}');
        debugPrint('Sample rate: ${info.sampleRate}');
        debugPrint('Channels: ${info.channels}');
      }
      debugPrint('Stream count: ${info.streamCount}');
      
      setState(() {
        _videoInfo = info;
        _extractionTimeMs = stopwatch.elapsedMilliseconds;
        _isLoading = false;
      });
    } on SmartVideoInfoException catch (e) {
      stopwatch.stop();
      debugPrint('SmartVideoInfoException: ${e.message}');
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      stopwatch.stop();
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _error = 'Unexpected error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Smart Video Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pick Video Button
            FilledButton.icon(
              onPressed: _isLoading ? null : _pickVideo,
              icon: const Icon(Icons.video_library),
              label: const Text('Select Video'),
            ),
            const SizedBox(height: 16),

            // Loading indicator
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Extracting metadata...'),
                  ],
                ),
              ),

            // Error message
            if (_error != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Video Info Display
            if (_videoInfo != null) ...[
              // Performance Card
              if (_extractionTimeMs != null)
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.speed),
                        const SizedBox(width: 8),
                        Text(
                          'Extraction time: ${_extractionTimeMs}ms',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              // File path
              if (_selectedPath != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'File',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedPath!.split('/').last,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              // Video Properties
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Video',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Divider(),
                      _InfoRow(
                        icon: Icons.aspect_ratio,
                        label: 'Resolution',
                        value: _videoInfo!.resolution,
                      ),
                      _InfoRow(
                        icon: Icons.timer,
                        label: 'Duration',
                        value: _formatDuration(_videoInfo!.duration),
                      ),
                      _InfoRow(
                        icon: Icons.movie,
                        label: 'Codec',
                        value: _videoInfo!.codec,
                      ),
                      _InfoRow(
                        icon: Icons.speed,
                        label: 'FPS',
                        value: _videoInfo!.fps.toStringAsFixed(2),
                      ),
                      _InfoRow(
                        icon: Icons.data_usage,
                        label: 'Bitrate',
                        value: _formatBitrate(_videoInfo!.bitrate),
                      ),
                      _InfoRow(
                        icon: Icons.rotate_right,
                        label: 'Rotation',
                        value: '${_videoInfo!.rotation}°',
                      ),
                      _InfoRow(
                        icon: Icons.folder,
                        label: 'Container',
                        value: _videoInfo!.container,
                      ),
                      _InfoRow(
                        icon: Icons.crop_landscape,
                        label: 'Orientation',
                        value:
                            _videoInfo!.isPortrait ? 'Portrait' : 'Landscape',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Audio Properties
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audio',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Divider(),
                      _InfoRow(
                        icon: _videoInfo!.hasAudio
                            ? Icons.volume_up
                            : Icons.volume_off,
                        label: 'Has Audio',
                        value: _videoInfo!.hasAudio ? 'Yes' : 'No',
                      ),
                      if (_videoInfo!.audioCodec != null)
                        _InfoRow(
                          icon: Icons.audiotrack,
                          label: 'Audio Codec',
                          value: _videoInfo!.audioCodec!,
                        ),
                      if (_videoInfo!.sampleRate != null)
                        _InfoRow(
                          icon: Icons.graphic_eq,
                          label: 'Sample Rate',
                          value: '${_videoInfo!.sampleRate} Hz',
                        ),
                      if (_videoInfo!.channels != null)
                        _InfoRow(
                          icon: Icons.surround_sound,
                          label: 'Channels',
                          value: _videoInfo!.channels == 2
                              ? 'Stereo (2)'
                              : '${_videoInfo!.channels}',
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Other Properties
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Other',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Divider(),
                      _InfoRow(
                        icon: Icons.subtitles,
                        label: 'Subtitles',
                        value: _videoInfo!.hasSubtitles ? 'Yes' : 'No',
                      ),
                      _InfoRow(
                        icon: Icons.stream,
                        label: 'Stream Count',
                        value: '${_videoInfo!.streamCount}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatBitrate(int bitrate) {
    if (bitrate >= 1000000) {
      return '${(bitrate / 1000000).toStringAsFixed(2)} Mbps';
    } else if (bitrate >= 1000) {
      return '${(bitrate / 1000).toStringAsFixed(0)} Kbps';
    }
    return '$bitrate bps';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
