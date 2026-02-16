# Release v1.2.0 - macOS & Web Platform Support

## 🎉 New Features

### macOS Support

- ✅ Native macOS implementation using AVFoundation
- ✅ Full metadata extraction for all video formats
- ✅ Consistent API with iOS implementation
- ✅ No external dependencies (system framework)
- ✅ Comprehensive test coverage

### Web Platform Support

- ✅ HTML5 Video API integration via JavaScript bridge
- ✅ Blob URL support for local file processing
- ✅ Multi-browser audio detection (Chrome, Firefox, Safari)
- ✅ Automatic MIME type detection
- ✅ Cross-browser compatibility

## 🔧 Improvements

### Web Audio Detection

- Fixed audio track detection using `canplay` event
- Changed preload strategy from `metadata` to `auto` for reliable audio loading
- Multi-method audio detection:
  - `mozHasAudio` for Firefox
  - `webkitAudioDecodedByteCount` for Chrome
  - `audioTracks` API for standard browsers

### Example App Enhancements

- Added web platform support with blob URL handling
- Improved MIME type detection for various video formats
- Enhanced logging for debugging
- Better error handling for web platform

## 📦 Platform Support

Now supporting **5 platforms**:

- ✅ Android (FFmpeg native API)
- ✅ iOS (AVFoundation)
- ✅ macOS (AVFoundation)
- ✅ Windows (Media Foundation)
- ✅ Web (HTML5 Video API)

## 🧪 Testing

- Added macOS integration tests
- Added web integration tests
- New test assets: `Broadcast_Woman.mp4`, `with_audio.mp4`
- All existing tests updated with new video samples

## 📝 Documentation

- Updated AGENTS.md with web architecture details
- Added macOS implementation summary
- Added example macOS setup guide
- Updated README with web platform instructions

## 🐛 Bug Fixes

- Fixed web audio detection not working with blob URLs
- Fixed compilation errors with deprecated `dart:js` APIs
- Fixed unused import warnings in example app

## 📊 Metadata Extraction

All platforms now extract:

- Video: width, height, duration, codec, fps, bitrate, rotation, container
- Audio: codec, sample rate, channels, presence detection
- Streams: total count, subtitle detection

## 🚀 Getting Started

### Web Platform Usage

```dart
import 'package:smart_video_info/smart_video_info.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html show Url, Blob;

// For web: create blob URL from file bytes
if (kIsWeb && bytes != null) {
  final blob = html.Blob([bytes], 'video/mp4');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final info = await SmartVideoInfoPlugin.getInfo(url);
}

// For native platforms: use file path
else {
  final info = await SmartVideoInfoPlugin.getInfo(filePath);
}
```

### macOS Platform

Works out of the box - no additional setup required!

```dart
final info = await SmartVideoInfoPlugin.getInfo('/path/to/video.mp4');
print('Resolution: ${info.resolution}');
print('Duration: ${info.duration}');
print('Has Audio: ${info.hasAudio}');
```

## 🔗 Links

- [GitHub Repository](https://github.com/Daronec/smart_video_info)
- [pub.dev Package](https://pub.dev/packages/smart_video_info)
- [Documentation](https://github.com/Daronec/smart_video_info#readme)

## 📈 Performance

- Android: <20ms average (FFmpeg native)
- iOS/macOS: <50ms average (AVFoundation)
- Windows: <100ms average (Media Foundation)
- Web: <1000ms average (HTML5 Video API, depends on file size)

## 🙏 Contributors

Thank you to everyone who contributed to this release!

---

**Full Changelog**: https://github.com/Daronec/smart_video_info/compare/v1.1.0...v1.2.0
