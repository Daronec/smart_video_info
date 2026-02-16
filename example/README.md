# smart_video_info Example

Example Flutter application demonstrating the smart_video_info plugin.

## Features

- Pick video files using native file picker
- Extract and display comprehensive video metadata
- Show extraction performance metrics
- Support for all platforms: Android, iOS, macOS, Windows

## Running the Example

### Android

```bash
flutter run -d android
```

### iOS

```bash
flutter run -d ios
```

### macOS

```bash
flutter run -d macos
```

### Windows

```bash
flutter run -d windows
```

## What It Demonstrates

The example app shows how to:

1. **Pick a video file** using the file_picker package
2. **Extract metadata** using SmartVideoInfoPlugin.getInfo()
3. **Display all metadata fields**:
   - Video: resolution, duration, codec, FPS, bitrate, rotation, container
   - Audio: codec, sample rate, channels
   - Other: subtitles, stream count
4. **Measure extraction performance** with a stopwatch
5. **Handle errors** gracefully with try-catch

## UI Features

- Material 3 design
- Responsive layout
- Performance metrics display
- Error handling with visual feedback
- Organized information cards

## Code Structure

```
lib/
└── main.dart          # Main application with video info display
```

The main.dart file contains:

- `MyApp`: Root application widget
- `VideoInfoPage`: Main page with file picker and info display
- `_InfoRow`: Reusable widget for displaying metadata rows

## Platform-Specific Notes

### macOS

- Requires macOS 10.14 or later
- Uses native AVFoundation framework
- File picker shows native macOS file dialog

### Windows

- Uses Media Foundation for metadata extraction
- File picker shows native Windows file dialog

### iOS

- Requires iOS 12.0 or later
- Uses native AVFoundation framework
- File picker shows native iOS document picker

### Android

- Uses smart-ffmpeg-android library
- File picker shows native Android file picker
