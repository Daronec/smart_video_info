# Requirements Document: macOS Video Metadata Extraction

## Introduction

This document specifies the requirements for implementing macOS platform support in the smart_video_info Flutter plugin. The implementation will enable ultra-fast video metadata extraction on macOS using the native AVFoundation framework, maintaining consistency with the existing iOS implementation while adhering to macOS-specific platform conventions.

## Glossary

- **Plugin**: The smart_video_info Flutter plugin that provides video metadata extraction capabilities
- **AVFoundation**: Apple's native framework for working with time-based audiovisual media
- **MethodChannel**: Flutter's platform channel mechanism for communication between Dart and native code
- **Metadata**: Video file properties including dimensions, duration, codec, bitrate, frame rate, rotation, and audio information
- **Background_Thread**: A non-UI thread used for processing operations to prevent blocking the main thread
- **JSON_Schema**: The standardized v1 format for metadata responses defined in the existing implementation
- **Batch_Processing**: Processing multiple video files in a single native method call
- **Video_Track**: A media track containing video data within a video file
- **Audio_Track**: A media track containing audio data within a video file
- **Subtitle_Track**: A media track containing subtitle/caption data within a video file

## Requirements

### Requirement 1: Native Plugin Implementation

**User Story:** As a Flutter developer, I want to extract video metadata on macOS, so that my cross-platform application can work consistently across all supported platforms.

#### Acceptance Criteria

1. THE Plugin SHALL implement a macOS platform plugin using Swift
2. THE Plugin SHALL use the AVFoundation framework for metadata extraction
3. THE Plugin SHALL register with the Flutter plugin registrar on macOS
4. THE Plugin SHALL communicate with Dart code via MethodChannel named "smart_video_info"
5. THE Plugin SHALL support macOS 10.14 or later

### Requirement 2: Metadata Extraction

**User Story:** As a developer, I want to extract comprehensive video metadata, so that I can display accurate video information to users.

#### Acceptance Criteria

1. WHEN a valid video file path is provided, THE Plugin SHALL extract the video width in pixels
2. WHEN a valid video file path is provided, THE Plugin SHALL extract the video height in pixels
3. WHEN a valid video file path is provided, THE Plugin SHALL extract the video duration in milliseconds
4. WHEN a valid video file path is provided, THE Plugin SHALL extract the video codec identifier
5. WHEN a valid video file path is provided, THE Plugin SHALL extract the video bitrate in bits per second
6. WHEN a valid video file path is provided, THE Plugin SHALL extract the frame rate in frames per second
7. WHEN a valid video file path is provided, THE Plugin SHALL extract the rotation angle in degrees (0, 90, 180, or 270)
8. WHEN a valid video file path is provided, THE Plugin SHALL extract the container format from the file extension
9. WHEN a video file contains an Audio_Track, THE Plugin SHALL extract the audio codec identifier
10. WHEN a video file contains an Audio_Track, THE Plugin SHALL extract the audio sample rate in Hz
11. WHEN a video file contains an Audio_Track, THE Plugin SHALL extract the number of audio channels
12. WHEN a valid video file path is provided, THE Plugin SHALL determine whether the video has audio
13. WHEN a valid video file path is provided, THE Plugin SHALL determine whether the video has subtitles
14. WHEN a valid video file path is provided, THE Plugin SHALL count the total number of streams in the container

### Requirement 3: Method Channel API

**User Story:** As a Flutter developer, I want to call native methods from Dart, so that I can integrate video metadata extraction into my application logic.

#### Acceptance Criteria

1. WHEN the "getInfo" method is invoked with a path argument, THE Plugin SHALL extract metadata for the single video file
2. WHEN the "getBatch" method is invoked with a paths argument, THE Plugin SHALL extract metadata for all video files in the list
3. WHEN an unsupported method is invoked, THE Plugin SHALL return FlutterMethodNotImplemented
4. WHEN method arguments are missing or invalid, THE Plugin SHALL return a FlutterError with code "INVALID_ARGUMENT"

### Requirement 4: JSON Response Format

**User Story:** As a developer, I want metadata returned in a consistent format, so that my Dart code can parse responses reliably across all platforms.

#### Acceptance Criteria

1. THE Plugin SHALL return metadata as a JSON string matching JSON_Schema v1
2. THE Plugin SHALL include a "success" field set to true in successful responses
3. THE Plugin SHALL include a "data" object containing all extracted metadata fields
4. WHEN audio is present, THE Plugin SHALL include audioCodec, sampleRate, and channels in the response
5. WHEN audio is absent, THE Plugin SHALL omit audioCodec, sampleRate, and channels from the response
6. THE Plugin SHALL encode all metadata values using appropriate JSON data types

### Requirement 5: Background Processing

**User Story:** As a developer, I want metadata extraction to run on a background thread, so that my application UI remains responsive during processing.

#### Acceptance Criteria

1. WHEN metadata extraction is initiated, THE Plugin SHALL execute the operation on a Background_Thread
2. WHEN metadata extraction completes, THE Plugin SHALL return the result on the main thread
3. WHEN Batch_Processing is initiated, THE Plugin SHALL execute all extractions on a Background_Thread
4. THE Plugin SHALL use a quality-of-service level appropriate for user-initiated work

### Requirement 6: Error Handling

**User Story:** As a developer, I want clear error messages when extraction fails, so that I can handle failures appropriately and inform users.

#### Acceptance Criteria

1. WHEN a file path does not exist, THE Plugin SHALL return a FlutterError with a descriptive message
2. WHEN a file is not a valid video, THE Plugin SHALL return a FlutterError with a descriptive message
3. WHEN a video file has no Video_Track, THE Plugin SHALL return a FlutterError with message "No video track found"
4. WHEN JSON encoding fails, THE Plugin SHALL return a FlutterError with a descriptive message
5. WHEN any extraction error occurs, THE Plugin SHALL include the error code "METADATA_ERROR"
6. WHEN Batch_Processing encounters an error, THE Plugin SHALL stop processing and return the error immediately

### Requirement 7: Video Format Support

**User Story:** As a developer, I want to extract metadata from common video formats, so that my application can handle videos from various sources.

#### Acceptance Criteria

1. THE Plugin SHALL support MP4 container format
2. THE Plugin SHALL support MOV container format
3. THE Plugin SHALL support M4V container format
4. THE Plugin SHALL support MKV container format
5. THE Plugin SHALL support AVI container format
6. THE Plugin SHALL support WebM container format
7. THE Plugin SHALL support FLV container format
8. THE Plugin SHALL support 3GP container format
9. THE Plugin SHALL support WMV container format
10. WHEN AVFoundation can load a video file, THE Plugin SHALL attempt to extract metadata regardless of container format

### Requirement 8: Codec Information Extraction

**User Story:** As a developer, I want to identify video and audio codecs, so that I can determine compatibility and display technical information.

#### Acceptance Criteria

1. WHEN extracting video codec information, THE Plugin SHALL convert the FourCC code to a string representation
2. WHEN extracting audio codec information, THE Plugin SHALL convert the FourCC code to a string representation
3. THE Plugin SHALL extract codec information from the format description of media tracks
4. WHEN multiple format descriptions exist, THE Plugin SHALL use the first format description

### Requirement 9: Rotation Handling

**User Story:** As a developer, I want to know the video rotation, so that I can display videos in the correct orientation.

#### Acceptance Criteria

1. WHEN a video has a preferred transform, THE Plugin SHALL calculate the rotation angle from the transform matrix
2. THE Plugin SHALL normalize rotation angles to 0, 90, 180, or 270 degrees
3. WHEN the rotation angle is between 85 and 95 degrees, THE Plugin SHALL return 90 degrees
4. WHEN the rotation angle is between 175 and 185 degrees or between -185 and -175 degrees, THE Plugin SHALL return 180 degrees
5. WHEN the rotation angle is between -95 and -85 degrees, THE Plugin SHALL return 270 degrees
6. WHEN the rotation angle does not match the above ranges, THE Plugin SHALL return 0 degrees

### Requirement 10: Batch Processing Efficiency

**User Story:** As a developer, I want to process multiple videos efficiently, so that I can extract metadata for large collections without performance degradation.

#### Acceptance Criteria

1. WHEN Batch_Processing is invoked, THE Plugin SHALL process all files in a single native method call
2. WHEN Batch_Processing is invoked, THE Plugin SHALL return results in the same order as the input paths
3. WHEN Batch_Processing is invoked, THE Plugin SHALL return a list of JSON strings
4. THE Plugin SHALL process batch requests on a Background_Thread

### Requirement 11: Resource Management

**User Story:** As a developer, I want proper resource cleanup, so that my application does not leak memory or file handles.

#### Acceptance Criteria

1. WHEN metadata extraction completes, THE Plugin SHALL release all AVAsset references
2. WHEN metadata extraction completes, THE Plugin SHALL release all track references
3. WHEN an error occurs during extraction, THE Plugin SHALL release all allocated resources before returning
4. THE Plugin SHALL rely on Swift's automatic reference counting for memory management

### Requirement 12: Thread Safety

**User Story:** As a developer, I want thread-safe metadata extraction, so that concurrent requests do not cause crashes or data corruption.

#### Acceptance Criteria

1. THE Plugin SHALL handle concurrent method channel calls safely
2. THE Plugin SHALL use separate dispatch queues for each extraction operation
3. THE Plugin SHALL return results on the main thread using DispatchQueue.main.async
4. THE Plugin SHALL not share mutable state between concurrent operations

### Requirement 13: Dimension Calculation

**User Story:** As a developer, I want accurate video dimensions, so that I can properly size video players and thumbnails.

#### Acceptance Criteria

1. WHEN calculating dimensions, THE Plugin SHALL apply the preferred transform to the natural size
2. WHEN calculating dimensions, THE Plugin SHALL use absolute values to handle negative dimensions from transforms
3. THE Plugin SHALL return width and height as integer values in pixels
4. THE Plugin SHALL extract dimensions from the Video_Track natural size property
