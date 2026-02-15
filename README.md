# smart_video_info

Ultra-fast video metadata extraction for Flutter, powered by Smart FFmpeg Engine.

![Screenshot](https://raw.githubusercontent.com/Daronec/smart_video_info/main/assets/screenshot.jpg)

## Features

- ⚡ **No FFmpeg CLI** — Direct native API access
- ⚡ **No process spawning** — Zero subprocess overhead
- ⚡ **Extremely fast** — Metadata extraction in <20ms
- ⚡ **Lightweight** — Minimal footprint
- ⚡ **Batch processing** — Extract metadata from multiple files efficiently

## Installation

```yaml
dependencies:
  smart_video_info: ^1.0.0
```

## Usage

```dart
import 'package:smart_video_info/smart_video_info.dart';

// Single file
final info = await SmartVideoInfoPlugin.getInfo('/path/to/video.mp4');
print('Resolution: ${info.resolution}');  // 1920x1080
print('Duration: ${info.duration}');       // 0:02:00.000000
print('Codec: ${info.codec}');             // h264
print('FPS: ${info.fps}');                 // 30.0
print('Has Audio: ${info.hasAudio}');      // true

// Batch processing (more efficient for multiple files)
final infos = await SmartVideoInfoPlugin.getBatch([
  '/path/to/video1.mp4',
  '/path/to/video2.mp4',
]);

// Check if file is supported
final supported = await SmartVideoInfoPlugin.isSupported('/path/to/file');

// Custom timeout
final info = await SmartVideoInfoPlugin.getInfo(
  '/path/to/video.mp4',
  timeout: Duration(seconds: 5),
);
```

## Available Properties

| Property       | Type       | Description                       |
| -------------- | ---------- | --------------------------------- |
| `width`        | `int`      | Video width in pixels             |
| `height`       | `int`      | Video height in pixels            |
| `duration`     | `Duration` | Video duration                    |
| `codec`        | `String`   | Video codec (h264, hevc, etc.)    |
| `bitrate`      | `int`      | Bitrate in bits/second            |
| `fps`          | `double`   | Frames per second                 |
| `rotation`     | `int`      | Rotation in degrees               |
| `container`    | `String`   | Container format (mp4, mkv, etc.) |
| `audioCodec`   | `String?`  | Audio codec if present            |
| `sampleRate`   | `int?`     | Audio sample rate in Hz           |
| `channels`     | `int?`     | Number of audio channels          |
| `hasAudio`     | `bool`     | Has audio track                   |
| `hasSubtitles` | `bool`     | Has subtitle tracks               |
| `streamCount`  | `int`      | Total stream count                |

### Computed Properties

- `resolution` — Resolution string ("1920x1080")
- `aspectRatio` — Width/height ratio
- `isLandscape` — Width > height
- `isPortrait` — Height > width

## Platform Support

| Platform | Status         |
| -------- | -------------- |
| Android  | ✅ Supported   |
| iOS      | 🚧 Coming soon |

## Benchmarks

```
Average metadata extraction time:
Smart Video Info: 14ms
video_player init: 82ms
```

## License

MIT
