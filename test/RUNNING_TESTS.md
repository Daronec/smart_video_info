# Running Integration Tests

## Prerequisites

1. Android device or emulator with API 26+ (Android 8.0+)
2. Video files in `test/assets/` directory
3. Flutter SDK installed

## Step-by-Step Guide

### 1. Start Android Emulator or Connect Device

```powershell
# Check available devices
flutter devices

# Example output:
# Android SDK built for x86 (mobile) • emulator-5554 • android-x86 • Android 11 (API 30)
# MGA LX3 (mobile)                   • HUAWEI_MGA_LX3 • android-arm64 • Android 9 (API 28)
```

### 2. Copy Test Videos to Device

The integration tests expect video files at specific paths. You have two options:

#### Option A: Use absolute paths (recommended for testing)

Modify the test file to use absolute paths on your device:

```dart
final testAssetsPath = '/sdcard/Download/test_videos';
```

Then copy videos to device:

```powershell
adb push test/assets/sample_1280x720.avi /sdcard/Download/test_videos/
adb push test/assets/sample_1280x720.webm /sdcard/Download/test_videos/
adb push test/assets/sample_1920x1080.3gp /sdcard/Download/test_videos/
adb push test/assets/sample_2560x1440.wmv /sdcard/Download/test_videos/
adb push test/assets/sample_640x360.mkv /sdcard/Download/test_videos/
adb push "test/assets/Подводный_мир_Красное_море_4K.mp4" /sdcard/Download/test_videos/
```

#### Option B: Bundle with app (for example app testing)

Add videos to example app assets and use them from there.

### 3. Run Integration Tests

```powershell
# Run all integration tests
flutter test --device-id=<your-device-id> test/integration_test.dart

# Run specific test
flutter test --device-id=<your-device-id> test/integration_test.dart --name "1280x720 AVI"

# Run with verbose output
flutter test --device-id=<your-device-id> test/integration_test.dart -v
```

### 4. Example Session

```powershell
PS C:\Work\smart_video_info> flutter devices
2 connected devices:

MGA LX3 (mobile) • HUAWEI_MGA_LX3 • android-arm64 • Android 9 (API 28)

PS C:\Work\smart_video_info> adb push test/assets/*.* /sdcard/Download/test_videos/
test/assets/sample_1280x720.avi: 1 file pushed, 0 skipped. 15.2 MB/s (2458624 bytes in 0.154s)
test/assets/sample_1280x720.webm: 1 file pushed, 0 skipped. 18.3 MB/s (1048576 bytes in 0.055s)
...

PS C:\Work\smart_video_info> flutter test --device-id=HUAWEI_MGA_LX3 test/integration_test.dart
00:15 +12: All tests passed!
```

## Troubleshooting

### Tests are skipped

If you see "Test skipped: Requires Android/iOS device", it means:

- Tests are running on desktop/web platform
- Use `--device-id` to specify mobile device

### File not found errors

- Verify files are copied to device: `adb shell ls /sdcard/Download/test_videos/`
- Check file permissions: `adb shell chmod 644 /sdcard/Download/test_videos/*`
- Update paths in test file to match your device structure

### Permission denied

Grant storage permissions to the test app:

```powershell
adb shell pm grant com.example.smart_video_info_example android.permission.READ_EXTERNAL_STORAGE
```

### Timeout errors

Increase timeout in test:

```dart
final info = await SmartVideoInfoPlugin.getInfo(
  path,
  timeout: const Duration(seconds: 30),
);
```

## Performance Expectations

On a typical Android device:

- Single video metadata extraction: 10-50ms
- Batch processing (3 videos): 30-150ms
- 4K video: 20-80ms

If tests fail performance checks, it may indicate:

- Slow device/emulator
- Large video files
- Device under heavy load
