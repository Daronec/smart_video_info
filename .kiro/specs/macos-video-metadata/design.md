# Design Document: macOS Video Metadata Extraction

## Overview

This design specifies the implementation of macOS platform support for the smart_video_info Flutter plugin. The implementation will mirror the existing iOS implementation, leveraging AVFoundation framework for native video metadata extraction. The design ensures consistency with existing platform implementations while adhering to macOS-specific conventions and Flutter plugin architecture.

The implementation will be written in Swift, using AVFoundation's AVAsset and AVAssetTrack APIs to extract comprehensive video metadata. All processing will occur on background threads to maintain UI responsiveness, with results returned via Flutter's MethodChannel mechanism.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Dart Layer                            │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  SmartVideoInfoPlugin (Dart)                           │ │
│  │  - getInfo(path) -> Future<SmartVideoInfo>             │ │
│  │  - getBatch(paths) -> Future<List<SmartVideoInfo>>     │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ MethodChannel
                            │ "smart_video_info"
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      macOS Native Layer                      │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  SmartVideoInfoPlugin (Swift)                          │ │
│  │  - handle(_ call, result)                              │ │
│  │  - getVideoMetadata(path, result)                      │ │
│  │  - getBatchMetadata(paths, result)                     │ │
│  │  - extractMetadata(path) -> String                     │ │
│  └────────────────────────────────────────────────────────┘ │
│                            │                                 │
│                            ▼                                 │
│  ┌────────────────────────────────────────────────────────┐ │
│  │           AVFoundation Framework                        │ │
│  │  - AVAsset: Load video file                            │ │
│  │  - AVAssetTrack: Extract track metadata                │ │
│  │  - CMFormatDescription: Get codec information          │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Threading Model

```
Main Thread                    Background Thread (QoS: userInitiated)
    │                                      │
    │ MethodChannel Call                   │
    ├──────────────────────────────────────>
    │                                      │
    │                                  Load AVAsset
    │                                      │
    │                                  Extract Tracks
    │                                      │
    │                                  Parse Metadata
    │                                      │
    │                                  Build JSON
    │                                      │
    │ <──────────────────────────────────┤
    │ Return Result                        │
    │                                      │
```

### File Structure

```
macos/
├── Classes/
│   └── SmartVideoInfoPlugin.swift    # Main plugin implementation
└── smart_video_info.podspec          # CocoaPods specification
```

## Components and Interfaces

### 1. Plugin Registration

The plugin registers with Flutter's plugin registrar to handle method channel calls.

```swift
public class SmartVideoInfoPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "smart_video_info",
            binaryMessenger: registrar.messenger
        )
        let instance = SmartVideoInfoPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
}
```

### 2. Method Channel Handler

The handler dispatches method calls to appropriate processing functions.

```swift
public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getInfo":
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGUMENT",
                message: "Path is required",
                details: nil
            ))
            return
        }
        getVideoMetadata(path: path, result: result)

    case "getBatch":
        guard let args = call.arguments as? [String: Any],
              let paths = args["paths"] as? [String] else {
            result(FlutterError(
                code: "INVALID_ARGUMENT",
                message: "Paths list is required",
                details: nil
            ))
            return
        }
        getBatchMetadata(paths: paths, result: result)

    default:
        result(FlutterMethodNotImplemented)
    }
}
```

### 3. Single File Metadata Extraction

Processes a single video file on a background thread.

```swift
private func getVideoMetadata(path: String, result: @escaping FlutterResult) {
    DispatchQueue.global(qos: .userInitiated).async {
        do {
            let jsonString = try self.extractMetadata(path: path)
            DispatchQueue.main.async {
                result(jsonString)
            }
        } catch {
            DispatchQueue.main.async {
                result(FlutterError(
                    code: "METADATA_ERROR",
                    message: error.localizedDescription,
                    details: nil
                ))
            }
        }
    }
}
```

### 4. Batch Metadata Extraction

Processes multiple video files sequentially on a background thread.

```swift
private func getBatchMetadata(paths: [String], result: @escaping FlutterResult) {
    DispatchQueue.global(qos: .userInitiated).async {
        var results: [String] = []

        for path in paths {
            do {
                let jsonString = try self.extractMetadata(path: path)
                results.append(jsonString)
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "METADATA_ERROR",
                        message: error.localizedDescription,
                        details: nil
                    ))
                }
                return
            }
        }

        DispatchQueue.main.async {
            result(results)
        }
    }
}
```

### 5. Core Metadata Extraction Logic

The core extraction function loads the video file and extracts all metadata fields.

```swift
private func extractMetadata(path: String) throws -> String {
    // Load video file
    let url = URL(fileURLWithPath: path)
    let asset = AVAsset(url: url)

    // Load video tracks
    let tracks = try asset.loadTracks(withMediaType: .video)
    guard let videoTrack = tracks.first else {
        throw NSError(
            domain: "SmartVideoInfo",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "No video track found"]
        )
    }

    // Extract video dimensions (apply transform for rotation)
    let size = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
    let width = Int(abs(size.width))
    let height = Int(abs(size.height))

    // Extract video properties
    let fps = videoTrack.nominalFrameRate
    let durationMs = Int(CMTimeGetSeconds(asset.duration) * 1000)
    let bitrate = Int(videoTrack.estimatedDataRate)

    // Extract rotation
    let transform = videoTrack.preferredTransform
    let rotation = getRotationFromTransform(transform)

    // Extract video codec
    let formatDescriptions = videoTrack.formatDescriptions as! [CMFormatDescription]
    var codec = ""
    if let formatDescription = formatDescriptions.first {
        let codecType = CMFormatDescriptionGetMediaSubType(formatDescription)
        codec = fourCCToString(codecType)
    }

    // Extract audio information
    let audioTracks = try asset.loadTracks(withMediaType: .audio)
    let hasAudio = !audioTracks.isEmpty

    var audioCodec: String? = nil
    var sampleRate: Int? = nil
    var channels: Int? = nil

    if let audioTrack = audioTracks.first {
        let audioFormatDescriptions = audioTrack.formatDescriptions as! [CMFormatDescription]
        if let audioFormatDescription = audioFormatDescriptions.first {
            let audioCodecType = CMFormatDescriptionGetMediaSubType(audioFormatDescription)
            audioCodec = fourCCToString(audioCodecType)

            if let basicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(audioFormatDescription) {
                sampleRate = Int(basicDescription.pointee.mSampleRate)
                channels = Int(basicDescription.pointee.mChannelsPerFrame)
            }
        }
    }

    // Check for subtitles
    let subtitleTracks = try asset.loadTracks(withMediaType: .subtitle)
    let hasSubtitles = !subtitleTracks.isEmpty

    // Get container format
    let container = url.pathExtension.lowercased()

    // Get total stream count
    let streamCount = asset.tracks.count

    // Build JSON response
    let data: [String: Any?] = [
        "width": width,
        "height": height,
        "duration": durationMs,
        "codec": codec,
        "bitrate": bitrate,
        "fps": Double(fps),
        "rotation": rotation,
        "container": container,
        "audioCodec": audioCodec,
        "sampleRate": sampleRate,
        "channels": channels,
        "hasAudio": hasAudio,
        "hasSubtitles": hasSubtitles,
        "streamCount": streamCount
    ]

    let json: [String: Any] = [
        "success": true,
        "data": data.compactMapValues { $0 }
    ]

    return try jsonToString(json)
}
```

### 6. Rotation Calculation

Converts the video's transform matrix to a rotation angle.

```swift
private func getRotationFromTransform(_ transform: CGAffineTransform) -> Int {
    let angle = atan2(transform.b, transform.a)
    let degrees = Int(angle * 180 / .pi)

    // Normalize to 0, 90, 180, 270
    switch degrees {
    case 85...95:
        return 90
    case 175...185, -185...(-175):
        return 180
    case -95...(-85):
        return 270
    default:
        return 0
    }
}
```

### 7. FourCC Codec Conversion

Converts a FourCC code to a human-readable string.

```swift
private func fourCCToString(_ fourCC: FourCharCode) -> String {
    let bytes: [CChar] = [
        CChar((fourCC >> 24) & 0xff),
        CChar((fourCC >> 16) & 0xff),
        CChar((fourCC >> 8) & 0xff),
        CChar(fourCC & 0xff),
        0
    ]
    return String(cString: bytes).trimmingCharacters(in: .whitespaces)
}
```

### 8. JSON Serialization

Converts a dictionary to a JSON string.

```swift
private func jsonToString(_ dict: [String: Any]) throws -> String {
    let data = try JSONSerialization.data(withJSONObject: dict, options: [])
    guard let string = String(data: data, encoding: .utf8) else {
        throw NSError(
            domain: "SmartVideoInfo",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON"]
        )
    }
    return string
}
```

## Data Models

### JSON Response Schema (v1)

The plugin returns metadata as a JSON string matching this schema:

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

### Field Specifications

| Field        | Type    | Required | Description                                 |
| ------------ | ------- | -------- | ------------------------------------------- |
| success      | boolean | Yes      | Always true for successful extraction       |
| data         | object  | Yes      | Container for metadata fields               |
| width        | integer | Yes      | Video width in pixels                       |
| height       | integer | Yes      | Video height in pixels                      |
| duration     | integer | Yes      | Duration in milliseconds                    |
| codec        | string  | Yes      | Video codec FourCC code                     |
| bitrate      | integer | Yes      | Video bitrate in bits/second                |
| fps          | number  | Yes      | Frame rate (frames per second)              |
| rotation     | integer | Yes      | Rotation angle (0, 90, 180, 270)            |
| container    | string  | Yes      | File extension (lowercase)                  |
| audioCodec   | string  | No       | Audio codec FourCC code (if audio present)  |
| sampleRate   | integer | No       | Audio sample rate in Hz (if audio present)  |
| channels     | integer | No       | Number of audio channels (if audio present) |
| hasAudio     | boolean | Yes      | Whether video has audio track               |
| hasSubtitles | boolean | Yes      | Whether video has subtitle tracks           |
| streamCount  | integer | Yes      | Total number of streams                     |

### Error Response

When extraction fails, the plugin returns a FlutterError:

```swift
FlutterError(
    code: "METADATA_ERROR",
    message: "Descriptive error message",
    details: nil
)
```

## Correctness Properties

_A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees._

### Core Metadata Extraction Properties

Property 1: All required metadata fields are extracted
_For any_ valid video file, extracting metadata should return a JSON response containing all required fields: width, height, duration, codec, bitrate, fps, rotation, container, hasAudio, hasSubtitles, and streamCount
**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.12, 2.13, 2.14**

Property 2: Dimensions are positive integers
_For any_ valid video file, the extracted width and height should be positive integer values
**Validates: Requirements 13.2, 13.3**

Property 3: Rotation is normalized
_For any_ valid video file, the extracted rotation angle should be exactly one of: 0, 90, 180, or 270 degrees
**Validates: Requirements 2.7, 9.2**

Property 4: Container matches file extension
_For any_ valid video file, the extracted container format should match the lowercase file extension
**Validates: Requirements 2.8**

Property 5: Stream count is positive
_For any_ valid video file, the extracted streamCount should be a positive integer (at least 1 for the video track)
**Validates: Requirements 2.14**

### Audio Metadata Properties

Property 6: Audio metadata completeness
_For any_ video file with audio, the extracted metadata should include non-null values for audioCodec, sampleRate, and channels, and hasAudio should be true
**Validates: Requirements 2.9, 2.10, 2.11, 2.12, 4.4**

Property 7: Audio metadata absence
_For any_ video file without audio, the extracted metadata should omit audioCodec, sampleRate, and channels fields, and hasAudio should be false
**Validates: Requirements 2.12, 4.5**

Property 8: Codec strings are non-empty
_For any_ valid video file, the video codec string should be non-empty, and if audio is present, the audio codec string should be non-empty
**Validates: Requirements 2.4, 8.1, 8.2**

### JSON Schema Properties

Property 9: JSON schema compliance
_For any_ successful metadata extraction, the returned JSON string should parse to an object with "success": true and a "data" object containing all required fields with correct data types (integers for width/height/duration/bitrate/sampleRate/channels/streamCount, string for codec/container/audioCodec, number for fps, boolean for hasAudio/hasSubtitles, integer 0/90/180/270 for rotation)
**Validates: Requirements 4.1, 4.2, 4.3, 4.6**

### Method Channel Properties

Property 10: getInfo extracts metadata
_For any_ valid video file path, calling getInfo should return metadata as a JSON string that can be parsed into a SmartVideoInfo object
**Validates: Requirements 3.1**

Property 11: getBatch preserves order and completeness
_For any_ list of valid video file paths, calling getBatch should return a list of JSON strings in the same order as the input paths, with the same length as the input list
**Validates: Requirements 3.2, 10.2, 10.3**

Property 12: Invalid arguments return error
_For any_ method call with missing or invalid arguments (null path, empty path, non-string path), the plugin should return a FlutterError with code "INVALID_ARGUMENT"
**Validates: Requirements 3.4**

### Error Handling Properties

Property 13: Non-existent files return error
_For any_ file path that does not exist, calling getInfo should return a FlutterError with code "METADATA_ERROR" and a descriptive message
**Validates: Requirements 6.1, 6.5**

Property 14: Invalid video files return error
_For any_ file that is not a valid video (e.g., text file, image file, corrupted video), calling getInfo should return a FlutterError with code "METADATA_ERROR" and a descriptive message
**Validates: Requirements 6.2, 6.5**

Property 15: Batch processing fails fast
_For any_ list of file paths where at least one path is invalid, calling getBatch should stop processing at the first error and return a FlutterError immediately without processing remaining files
**Validates: Requirements 6.6**

### Format Support Properties

Property 16: Common video formats are supported
_For any_ video file in a common format (mp4, mov, m4v, mkv, avi, webm, flv, 3gp, wmv), the plugin should successfully extract metadata without errors
**Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9**

Property 17: AVFoundation-compatible formats are handled
_For any_ video file that AVFoundation can load (regardless of container format), the plugin should attempt to extract metadata and either succeed or return a descriptive error
**Validates: Requirements 7.10**

### Concurrency Properties

Property 18: Concurrent calls are safe
_For any_ set of concurrent method channel calls (multiple getInfo or getBatch calls), all calls should complete successfully without crashes, deadlocks, or data corruption
**Validates: Requirements 12.1**

## Error Handling

### Error Categories

1. **Invalid Arguments**
   - Missing path parameter
   - Null or empty path
   - Invalid argument types
   - Error code: `INVALID_ARGUMENT`

2. **File Not Found**
   - Path does not exist
   - Path is not accessible
   - Error code: `METADATA_ERROR`
   - Message: "File not found" or system error description

3. **Invalid Video File**
   - File is not a video
   - File is corrupted
   - Unsupported format
   - Error code: `METADATA_ERROR`
   - Message: Descriptive error from AVFoundation

4. **No Video Track**
   - File loads but contains no video track
   - Error code: `METADATA_ERROR`
   - Message: "No video track found"

5. **JSON Encoding Failure**
   - Internal error serializing metadata to JSON
   - Error code: `METADATA_ERROR`
   - Message: "Failed to encode JSON"

### Error Handling Strategy

All errors are caught and returned as `FlutterError` objects with:

- `code`: Error category identifier
- `message`: Human-readable description
- `details`: nil (not used)

Errors are always returned on the main thread via `DispatchQueue.main.async` to ensure Flutter can process them safely.

For batch processing, the fail-fast strategy ensures that the first error stops processing immediately, preventing wasted work on remaining files.

## Testing Strategy

### Dual Testing Approach

The implementation will use both unit tests and property-based tests for comprehensive coverage:

- **Unit tests**: Verify specific examples, edge cases, and error conditions
- **Property tests**: Verify universal properties across all inputs

Both testing approaches are complementary and necessary. Unit tests catch concrete bugs in specific scenarios, while property tests verify general correctness across a wide range of inputs.

### Property-Based Testing

**Framework**: Use the `fast_check` library for Dart/Flutter property-based testing, or implement tests using the existing integration test framework with randomized inputs.

**Configuration**:

- Minimum 100 iterations per property test (due to randomization)
- Each property test must reference its design document property
- Tag format: `// Feature: macos-video-metadata, Property N: [property text]`

**Property Test Coverage**:

- Each correctness property listed above must be implemented as a single property-based test
- Tests should generate random video files with varying characteristics (dimensions, codecs, with/without audio, etc.)
- Tests should use real video files from the test assets directory

### Unit Testing

**Focus Areas**:

- Specific examples demonstrating correct behavior
- Edge cases: empty files, very large files, unusual dimensions
- Error conditions: non-existent files, corrupted files, invalid formats
- Integration points: MethodChannel communication, JSON parsing

**Test Organization**:

```
test/
├── smart_video_info_test.dart           # Existing model tests
├── integration_test.dart                # Existing integration tests
└── macos_integration_test.dart          # New macOS-specific tests
```

### Test Assets

Reuse existing test assets from `test/assets/`:

- Various video formats (mp4, mov, mkv, avi, webm, flv, 3gp, wmv)
- Different resolutions (640x360, 1280x720, 1920x1080, 2560x1440, 3840x2160)
- Portrait and landscape orientations
- Videos with and without audio
- Videos with subtitles
- Rotated videos
- HEVC/H.265 encoded videos

### Performance Testing

- Extraction should complete in <100ms for small files
- Batch processing of 5 files should complete in <500ms
- No memory leaks during repeated extractions
- Concurrent calls should not degrade performance significantly

### Platform-Specific Testing

Tests must run on actual macOS devices or simulators:

```bash
flutter test --device-id=macos test/macos_integration_test.dart
```

### Continuous Integration

- Run tests on macOS in CI pipeline
- Test on multiple macOS versions (10.14, 11.0, 12.0, 13.0, 14.0)
- Verify no regressions in existing iOS, Android, Windows implementations

## Implementation Notes

### CocoaPods Specification

The `smart_video_info.podspec` file must be created for macOS:

```ruby
Pod::Spec.new do |s|
  s.name             = 'smart_video_info'
  s.version          = '1.0.0'
  s.summary          = 'Ultra-fast video metadata extraction for Flutter'
  s.description      = 'Flutter plugin for extracting video metadata using native APIs'
  s.homepage         = 'https://github.com/yourusername/smart_video_info'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
```

### Plugin Registration

The plugin must be registered in the macOS plugin registry. Flutter will automatically detect the plugin if the directory structure is correct:

```
macos/
├── Classes/
│   └── SmartVideoInfoPlugin.swift
└── smart_video_info.podspec
```

### Code Reuse from iOS

The macOS implementation is nearly identical to the iOS implementation since both use AVFoundation. The main differences:

- Import `FlutterMacOS` instead of `Flutter`
- Use `FlutterPlugin` protocol (same on both platforms)
- No UIKit dependency (macOS uses AppKit, but we don't need it)

### Synchronous vs Asynchronous Loading

AVFoundation's `loadTracks(withMediaType:)` is an async method in modern Swift. The implementation uses `try asset.loadTracks(withMediaType: .video)` which works synchronously in the context of a background thread.

### Memory Management

Swift's Automatic Reference Counting (ARC) handles memory management automatically. No manual cleanup is required for AVAsset or AVAssetTrack objects.

### Thread Safety

Each method call creates its own dispatch queue task, ensuring isolation between concurrent requests. No shared mutable state exists between calls.

### Performance Considerations

- AVFoundation loads metadata lazily, only reading what's needed
- No video decoding occurs, only metadata parsing
- Background thread execution prevents UI blocking
- Batch processing is sequential but efficient (no overhead from multiple method calls)
