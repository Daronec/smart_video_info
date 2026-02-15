/// Video metadata extracted by Smart FFmpeg Engine.
class SmartVideoInfo {
  /// Video width in pixels.
  final int width;

  /// Video height in pixels.
  final int height;

  /// Video duration.
  final Duration duration;

  /// Video codec (e.g., "h264", "hevc").
  final String codec;

  /// Video bitrate in bits per second.
  final int bitrate;

  /// Frames per second.
  final double fps;

  /// Video rotation in degrees (0, 90, 180, 270).
  final int rotation;

  /// Container format (e.g., "mp4", "mkv").
  final String container;

  /// Audio codec if present (e.g., "aac", "mp3").
  final String? audioCodec;

  /// Audio sample rate in Hz.
  final int? sampleRate;

  /// Number of audio channels.
  final int? channels;

  /// Whether video has audio track.
  final bool hasAudio;

  /// Whether video has subtitle tracks.
  final bool hasSubtitles;

  /// Total number of streams in container.
  final int streamCount;

  /// Creates a new [SmartVideoInfo] instance.
  ///
  /// In debug mode, validates that numeric fields are non-negative.
  const SmartVideoInfo({
    required this.width,
    required this.height,
    required this.duration,
    required this.codec,
    required this.bitrate,
    required this.fps,
    required this.rotation,
    required this.container,
    this.audioCodec,
    this.sampleRate,
    this.channels,
    required this.hasAudio,
    required this.hasSubtitles,
    required this.streamCount,
  })  : assert(width >= 0, 'width must be non-negative'),
        assert(height >= 0, 'height must be non-negative'),
        assert(bitrate >= 0, 'bitrate must be non-negative'),
        assert(fps >= 0, 'fps must be non-negative'),
        assert(streamCount >= 0, 'streamCount must be non-negative');

  /// Creates instance from JSON map returned by native layer.
  ///
  /// Throws [FormatException] if required fields are missing.
  factory SmartVideoInfo.fromJson(Map<String, dynamic> json) {
    if (json['width'] == null || json['height'] == null) {
      throw FormatException('Invalid metadata: missing width or height');
    }

    return SmartVideoInfo(
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      duration: Duration(milliseconds: json['duration'] as int? ?? 0),
      codec: json['codec'] as String? ?? '',
      bitrate: json['bitrate'] as int? ?? 0,
      fps: (json['fps'] as num?)?.toDouble() ?? 0.0,
      rotation: json['rotation'] as int? ?? 0,
      container: json['container'] as String? ?? '',
      audioCodec: json['audioCodec'] as String?,
      sampleRate: json['sampleRate'] as int?,
      channels: json['channels'] as int?,
      hasAudio: json['hasAudio'] as bool? ?? false,
      hasSubtitles: json['hasSubtitles'] as bool? ?? false,
      streamCount: json['streamCount'] as int? ?? 0,
    );
  }

  /// Returns true if this is a portrait video (height > width).
  bool get isPortrait => height > width;

  /// Returns true if this is a landscape video (width > height).
  bool get isLandscape => width > height;

  /// Returns aspect ratio as width/height.
  double get aspectRatio => height > 0 ? width / height : 0.0;

  /// Returns resolution string (e.g., "1920x1080").
  String get resolution => '${width}x$height';

  @override
  String toString() {
    return 'SmartVideoInfo(resolution: $resolution, duration: $duration, '
        'codec: $codec, fps: $fps, hasAudio: $hasAudio)';
  }
}
