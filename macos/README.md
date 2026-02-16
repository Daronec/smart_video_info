# macOS Implementation

This directory contains the macOS platform implementation for the smart_video_info Flutter plugin.

## Architecture

The macOS implementation uses Apple's native AVFoundation framework for video metadata extraction, providing ultra-fast performance without any external dependencies.

### Key Components

- **SmartVideoInfoPlugin.swift**: Main plugin class that handles method channel communication
- **smart_video_info.podspec**: CocoaPods specification for macOS platform

### Features

- ✅ Single file metadata extraction via `getInfo()`
- ✅ Batch processing via `getBatch()`
- ✅ Background thread processing for UI responsiveness
- ✅ Comprehensive error handling
- ✅ Support for all common video formats (MP4, MOV, MKV, AVI, WebM, FLV, 3GP, WMV)

### Metadata Extracted

- Video dimensions (width, height)
- Duration (milliseconds)
- Video codec (FourCC code)
- Bitrate (bits/second)
- Frame rate (FPS)
- Rotation angle (0, 90, 180, 270)
- Container format
- Audio codec (if present)
- Audio sample rate (if present)
- Audio channels (if present)
- Audio presence flag
- Subtitle presence flag
- Total stream count

### Technical Details

**Framework**: AVFoundation (system framework, no external dependencies)

**Language**: Swift 5.0

**Minimum macOS Version**: 10.14 (Mojave)

**Threading**: All metadata extraction occurs on background threads with QoS `.userInitiated`

**Error Handling**: All errors are caught and returned as `FlutterError` with descriptive messages

### JSON Response Format

```json
{
  "success": true,
  "data": {
    "width": 1920,
    "height": 1080,
    "duration": 120000,
    "codec": "avc1",
    "bitrate": 5000000,
    "fps": 30.0,
    "rotation": 0,
    "container": "mp4",
    "audioCodec": "mp4a",
    "sampleRate": 44100,
    "channels": 2,
    "hasAudio": true,
    "hasSubtitles": false,
    "streamCount": 2
  }
}
```

### Testing

The implementation includes comprehensive tests:

- Unit tests for data model parsing
- Integration tests with real video files
- Property-based tests for correctness validation
- Performance tests for extraction speed
- Error handling tests

Run tests on macOS:

```bash
flutter test test/macos_integration_test.dart
```

### Performance

- Single file extraction: <100ms
- Batch processing (5 files): <500ms
- No memory leaks with repeated extractions
- Thread-safe concurrent operations

### Implementation Notes

The macOS implementation is nearly identical to the iOS implementation since both use AVFoundation. The main differences:

- Import `FlutterMacOS` instead of `Flutter`
- Minimum OS version is macOS 10.14 instead of iOS 12.0
- No UIKit dependency (macOS uses AppKit, but we don't need it)

### Future Enhancements

Potential improvements for future versions:

- Hardware acceleration detection
- HDR metadata extraction
- Color space information
- Advanced audio track selection
- Thumbnail generation
