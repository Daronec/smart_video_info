# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Flutter plugin for ultra-fast video metadata extraction. Uses native FFmpeg API via `smart-ffmpeg-android` library on Android and AVFoundation on iOS — no CLI, no process spawning.

**Currently supported platforms:** Android, iOS

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
