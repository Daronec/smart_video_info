# Tests

This directory contains tests for the smart_video_info plugin.

## Test Types

### Unit Tests (`smart_video_info_test.dart`)

Tests for data models and parsing logic. Can run without a device:

```powershell
flutter test test/smart_video_info_test.dart
```

### Integration Tests (`integration_test.dart`)

Tests with real video files from `test/assets/`. Requires an Android device or emulator:

```powershell
# List available devices
flutter devices

# Run integration tests on specific device
flutter test --device-id=<device-id> test/integration_test.dart

# Run on connected Android device
flutter test --device-id=android test/integration_test.dart
```

## Test Assets

The `test/assets/` directory contains sample video files in various formats:

- `sample_640x360.mkv` - MKV format, 640x360 resolution
- `sample_1280x720.avi` - AVI format, 1280x720 resolution
- `sample_1280x720.webm` - WebM format, 1280x720 resolution
- `sample_1920x1080.3gp` - 3GP format, 1920x1080 resolution
- `sample_2560x1440.wmv` - WMV format, 2560x1440 resolution
- `Подводный_мир_Красное_море_4K.mp4` - MP4 format, 4K resolution, Cyrillic filename

These files are used to test:

- Different video codecs (H.264, VP8/VP9, WMV, etc.)
- Different containers (MP4, AVI, MKV, WebM, 3GP, WMV)
- Various resolutions (360p to 4K)
- Unicode filenames support
- Audio stream detection
- Metadata extraction accuracy

## Running All Tests

```powershell
# Unit tests only (no device needed)
flutter test

# All tests including integration (requires device)
flutter test --device-id=android
```

## Performance Benchmarks

Integration tests include performance checks:

- Single file extraction: < 100ms
- Batch processing (3 files): < 300ms

These benchmarks ensure the plugin maintains its "ultra-fast" promise.
