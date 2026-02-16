# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Flutter plugin for ultra-fast video metadata extraction. Uses native FFmpeg API via `smart-ffmpeg-android` library on Android and AVFoundation on iOS — no CLI, no process spawning.

**Currently supported platforms:** Android, iOS, macOS, Windows, Web

## Architecture

### Android

```
lib/
├── smart_video_info.dart          # Library entry point (exports)
└── src/
    ├── smart_video_info_model.dart   # SmartVideoInfo data class
    └── smart_video_info_plugin.dart  # MethodChannel API

android/
├── build.gradle.kts               # Plugin build config + smart-ffmpeg-android dependency
└── src/main/kotlin/.../SmartVideoInfoPlugin.kt  # Kotlin bridge
```

### iOS

```
lib/
├── smart_video_info.dart          # Library entry point (exports)
└── src/
    ├── smart_video_info_model.dart   # SmartVideoInfo data class
    └── smart_video_info_plugin.dart  # MethodChannel API

ios/
├── smart_video_info.podspec       # CocoaPods spec
└── Classes/
    └── SmartVideoInfoPlugin.swift # Swift bridge using AVFoundation
```

### macOS

```
lib/
├── smart_video_info.dart          # Library entry point (exports)
└── src/
    ├── smart_video_info_model.dart   # SmartVideoInfo data class
    └── smart_video_info_plugin.dart  # MethodChannel API

macos/
├── smart_video_info.podspec       # CocoaPods spec
└── Classes/
    └── SmartVideoInfoPlugin.swift # Swift bridge using AVFoundation
```

### Windows

```
lib/
├── smart_video_info.dart          # Library entry point (exports)
└── src/
    ├── smart_video_info_model.dart   # SmartVideoInfo data class
    └── smart_video_info_plugin.dart  # MethodChannel API

windows/
├── include/
│   └── smart_video_info/
│       └── smart_video_info_plugin.h  # Plugin header
├── CMakeLists.txt                 # Plugin build config
└── smart_video_info_plugin.cpp    # C++ bridge using Media Foundation
```

### Web

```
lib/
├── smart_video_info.dart          # Library entry point (exports)
└── src/
    ├── smart_video_info_model.dart   # SmartVideoInfo data class
    ├── smart_video_info_plugin.dart  # MethodChannel API
    └── smart_video_info_web.dart    # Web implementation (Dart bridge)

web/
└── smart_video_info.js            # JavaScript implementation using HTML5 Video API
```

### Data Flow

#### Android

1. Dart calls `SmartVideoInfoPlugin.getInfo(path)` via MethodChannel
2. Kotlin plugin receives call on IO thread
3. `SmartFfmpegBridge.getVideoMetadataJson(path)` extracts metadata
4. JSON response parsed into `SmartVideoInfo` model

#### iOS

1. Dart calls `SmartVideoInfoPlugin.getInfo(path)` via MethodChannel
2. Swift plugin receives call
3. `AVAsset` loads video metadata asynchronously
4. Metadata extracted from video/audio tracks
5. JSON response parsed into `SmartVideoInfo` model

#### macOS

1. Dart calls `SmartVideoInfoPlugin.getInfo(path)` via MethodChannel
2. Swift plugin receives call
3. `AVAsset` loads video metadata asynchronously
4. Metadata extracted from video/audio tracks
5. JSON response parsed into `SmartVideoInfo` model

#### Windows

1. Dart calls `SmartVideoInfoPlugin.getInfo(path)` via MethodChannel
2. C++ plugin receives call
3. `IMFSourceReader` loads video metadata via Media Foundation
4. Metadata extracted from video/audio streams
5. JSON response parsed into `SmartVideoInfo` model

#### Web

1. Dart calls `SmartVideoInfoPlugin.getInfo(url)` (kIsWeb check routes to web implementation)
2. Dart web layer calls JavaScript via dart:js bridge
3. JavaScript creates HTML5 Video element
4. Video element loads metadata from URL (http://, https://, blob:)
5. JavaScript extracts available metadata (width, height, duration, etc.)
6. Codec estimated from URL pattern, defaults used for bitrate/fps/rotation
7. JSON response returned to Dart layer
8. Parsed into `SmartVideoInfo` model

### JSON Schema (v1)

```json
{
  "success": true,
  "data": {
    "width": int,
    "height": int,
    "duration": int,        // milliseconds
    "codec": string,
    "bitrate": int,
    "fps": double,
    "rotation": int,
    "container": string,
    "audioCodec": string?,
    "sampleRate": int?,
    "channels": int?,
    "hasAudio": bool,
    "hasSubtitles": bool,
    "streamCount": int
  }
}
```

## Commands

### Testing

```powershell
flutter test                                    # Run all tests
flutter test test/smart_video_info_test.dart   # Run specific test
```

### Code Quality

```powershell
flutter analyze              # Static analysis
dart format lib test         # Format code
flutter pub get              # Get dependencies
```

### Publishing

```powershell
dart pub publish --dry-run   # Validate before publish
dart pub publish             # Publish to pub.dev
```

## Dependencies

### Android

- **smart-ffmpeg-android** (JitPack): Native FFmpeg library providing `SmartFfmpegBridge.getVideoMetadataJson()`
- **kotlinx-coroutines-android**: For IO thread execution in Kotlin

### iOS

- **AVFoundation**: Native Apple framework for media processing (system framework, no external dependencies)

### Windows

- **Media Foundation**: Native Windows framework for media processing (system framework, no external dependencies)

### macOS

- **AVFoundation**: Native Apple framework for media processing (system framework, no external dependencies)

### Web

- **HTML5 Video API**: Browser-provided API for video metadata extraction (no external dependencies)
- **dart:html**: Dart web library for DOM manipulation (deprecated, but functional)
- **dart:js**: Dart-JavaScript interop for calling JavaScript functions
