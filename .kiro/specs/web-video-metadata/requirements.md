# Requirements Document

## Introduction

This document specifies requirements for implementing web platform support in the smart_video_info Flutter plugin. The web implementation will enable video metadata extraction in Flutter web applications using the HTML5 Video API and JavaScript bridge, maintaining compatibility with the existing plugin architecture used by Android (FFmpeg), iOS/macOS (AVFoundation), and Windows (Media Foundation) platforms.

The web platform has inherent limitations compared to native platforms: it only supports URL-based video loading (no local file system access), provides limited metadata through the HTML5 Video API (no direct codec/bitrate/fps access), and requires estimation or detection of certain properties. Despite these constraints, the implementation must conform to the same JSON schema v1 used by all other platforms to ensure consistent API behavior across platforms.

## Glossary

- **HTML5_Video_API**: Browser-provided JavaScript API for video element manipulation and metadata access
- **JavaScript_Bridge**: Dart-JavaScript interop layer using dart:js for communication between Flutter web and JavaScript
- **Video_Element**: HTML video DOM element used to load and inspect video metadata
- **URL_Video**: Video accessible via http://, https://, or blob: URL schemes
- **JSON_Schema_v1**: Standardized metadata format used across all platforms (success, data fields with width, height, duration, codec, bitrate, fps, rotation, container, audio properties, hasAudio, hasSubtitles, streamCount)
- **Metadata_Extraction**: Process of loading video and reading available properties from Video_Element
- **CORS**: Cross-Origin Resource Sharing - browser security mechanism that may block video loading from different origins
- **Timeout_Handler**: Mechanism to prevent indefinite waiting during video metadata loading
- **Batch_Processing**: Sequential extraction of metadata from multiple videos
- **Web_Directory**: Project root web/ directory containing JavaScript implementation files

## Requirements

### Requirement 1: JavaScript Implementation Architecture

**User Story:** As a Flutter web developer, I want the web platform to use a proper JavaScript implementation in the web/ directory, so that the plugin follows Flutter web plugin best practices and maintains separation between Dart and JavaScript code.

#### Acceptance Criteria

1. THE System SHALL implement video metadata extraction logic in web/smart_video_info.js
2. THE JavaScript_Implementation SHALL expose a SmartVideoInfoWeb class on the window object
3. THE JavaScript_Implementation SHALL provide getInfo, getBatch, and extractMetadata methods
4. THE System SHALL place all JavaScript files in the web/ directory at project root
5. THE Dart_Layer SHALL communicate with JavaScript_Implementation using dart:js interop

### Requirement 2: URL-Based Video Loading

**User Story:** As a Flutter web developer, I want to extract metadata from videos accessible via URLs, so that I can analyze videos hosted on servers or created as blob URLs in the browser.

#### Acceptance Criteria

1. WHEN a URL starts with "http://", "https://", or "blob:" THEN THE System SHALL accept it as valid input
2. WHEN a path does not start with "http://", "https://", or "blob:" THEN THE System SHALL reject it with error message "Web platform only supports URLs (http://, https://, blob:)"
3. THE System SHALL create a Video_Element with the provided URL as src attribute
4. THE System SHALL set Video_Element preload attribute to "metadata" for efficient loading
5. THE System SHALL add Video_Element to DOM temporarily during metadata extraction
6. WHEN metadata extraction completes or fails THEN THE System SHALL remove Video_Element from DOM

### Requirement 3: HTML5 Video API Metadata Extraction

**User Story:** As a Flutter web developer, I want to extract all available video metadata from the HTML5 Video API, so that I can get comprehensive video information within browser capabilities.

#### Acceptance Criteria

1. WHEN Video_Element fires "loadedmetadata" event THEN THE System SHALL extract width from videoWidth property
2. WHEN Video_Element fires "loadedmetadata" event THEN THE System SHALL extract height from videoHeight property
3. WHEN Video_Element fires "loadedmetadata" event THEN THE System SHALL extract duration in milliseconds by multiplying duration property by 1000
4. WHEN width equals 0 or height equals 0 THEN THE System SHALL throw error "Invalid video dimensions"
5. THE System SHALL extract container format from URL file extension
6. THE System SHALL detect hasAudio by checking mozHasAudio, webkitAudioDecodedByteCount, or audioTracks.length
7. THE System SHALL detect hasSubtitles by checking textTracks.length
8. THE System SHALL calculate streamCount as 1 (video) plus number of audio tracks

### Requirement 4: Codec Detection and Estimation

**User Story:** As a Flutter web developer, I want the system to estimate video codec from available information, so that I can get useful codec information despite HTML5 API limitations.

#### Acceptance Criteria

1. WHEN URL contains ".mp4" or ".m4v" THEN THE System SHALL set codec to "h264"
2. WHEN URL contains ".webm" THEN THE System SHALL set codec to "vp8"
3. WHEN URL contains ".ogv" THEN THE System SHALL set codec to "theora"
4. WHEN codec cannot be detected from URL THEN THE System SHALL set codec to "unknown"
5. THE System SHALL set bitrate to 0 for all videos (not available in HTML5 API)
6. THE System SHALL set fps to 30.0 for all videos (default assumption)
7. THE System SHALL set rotation to 0 for all videos (not available in HTML5 API)

### Requirement 5: Audio Metadata Handling

**User Story:** As a Flutter web developer, I want to get audio metadata when available, so that I can understand the complete media composition.

#### Acceptance Criteria

1. WHEN hasAudio is true THEN THE System SHALL set audioCodec to "unknown"
2. WHEN hasAudio is true THEN THE System SHALL set sampleRate to 44100 (default assumption)
3. WHEN hasAudio is true THEN THE System SHALL set channels to 2 (default stereo assumption)
4. WHEN hasAudio is false THEN THE System SHALL set audioCodec, sampleRate, and channels to null
5. THE System SHALL include audio metadata in JSON response following JSON_Schema_v1 format

### Requirement 6: Error Handling

**User Story:** As a Flutter web developer, I want comprehensive error handling for various failure scenarios, so that my application can gracefully handle issues like network errors, CORS restrictions, and invalid videos.

#### Acceptance Criteria

1. WHEN Video_Element fires "error" event THEN THE System SHALL reject with error message from video.error.message or "Failed to load video"
2. WHEN Video_Element creation fails THEN THE System SHALL reject with error message "Error creating video element"
3. WHEN metadata extraction throws exception THEN THE System SHALL reject with error message "Failed to extract metadata"
4. WHEN URL validation fails THEN THE System SHALL reject before creating Video_Element
5. IF Video_Element is created THEN THE System SHALL ensure it is removed from DOM even when errors occur
6. THE System SHALL return JSON response with success: false and error field for all failures

### Requirement 7: Timeout Handling

**User Story:** As a Flutter web developer, I want metadata extraction to timeout after a reasonable duration, so that my application doesn't hang indefinitely on slow or unresponsive videos.

#### Acceptance Criteria

1. THE System SHALL implement a 10-second timeout for metadata extraction
2. WHEN 10 seconds elapse without "loadedmetadata" event THEN THE System SHALL reject with error "Metadata extraction timed out"
3. WHEN timeout occurs THEN THE System SHALL remove Video_Element from DOM
4. WHEN timeout occurs THEN THE System SHALL clear timeout handler to prevent memory leaks
5. WHEN "loadedmetadata" event fires THEN THE System SHALL clear timeout handler before processing metadata

### Requirement 8: Batch Processing Support

**User Story:** As a Flutter web developer, I want to extract metadata from multiple videos efficiently, so that I can process video collections without writing complex iteration logic.

#### Acceptance Criteria

1. THE System SHALL provide getBatch method accepting array of URL strings
2. WHEN getBatch is called with empty array THEN THE System SHALL return empty array
3. WHEN getBatch is called THEN THE System SHALL process URLs sequentially
4. WHEN any URL in batch fails THEN THE System SHALL reject entire batch operation with error
5. THE System SHALL return array of JSON response strings in same order as input URLs
6. WHEN all URLs succeed THEN THE System SHALL return array with success: true for each result

### Requirement 9: JSON Schema v1 Compliance

**User Story:** As a Flutter plugin developer, I want the web implementation to return the same JSON schema as other platforms, so that the Dart layer can parse responses consistently across all platforms.

#### Acceptance Criteria

1. THE System SHALL return JSON with top-level "success" boolean field
2. WHEN extraction succeeds THEN THE System SHALL set success to true and include "data" object
3. WHEN extraction fails THEN THE System SHALL set success to false and include "error" string
4. THE data object SHALL include fields: width, height, duration, codec, bitrate, fps, rotation, container, hasAudio, hasSubtitles, streamCount
5. WHEN hasAudio is true THEN THE data object SHALL include audioCodec, sampleRate, channels fields
6. WHEN hasAudio is false THEN THE data object SHALL NOT include audioCodec, sampleRate, channels fields
7. THE System SHALL ensure all numeric fields are numbers (not strings)
8. THE System SHALL ensure duration is in milliseconds as integer

### Requirement 10: Dart-JavaScript Bridge Integration

**User Story:** As a Flutter plugin developer, I want seamless integration between Dart and JavaScript code, so that the web platform works transparently with the existing plugin API.

#### Acceptance Criteria

1. THE Dart_Layer SHALL use dart:js library to call JavaScript functions
2. THE Dart_Layer SHALL instantiate SmartVideoInfoWeb JavaScript class using JsObject constructor
3. THE Dart_Layer SHALL convert JavaScript Promises to Dart Futures using promiseToFuture
4. THE Dart_Layer SHALL parse JSON strings returned from JavaScript into Dart Map objects
5. THE Dart_Layer SHALL handle JavaScript exceptions and convert them to SmartVideoInfoException
6. THE System SHALL maintain same public API as other platforms (getInfo, getBatch, isSupported methods)
7. WHEN kIsWeb is true THEN THE System SHALL route calls to web implementation instead of MethodChannel

### Requirement 11: Video Element Configuration

**User Story:** As a Flutter web developer, I want video elements to be configured optimally for metadata extraction, so that loading is fast and doesn't interfere with the page.

#### Acceptance Criteria

1. THE System SHALL set Video_Element preload attribute to "metadata" (not "auto" or "none")
2. THE System SHALL set Video_Element muted attribute to true
3. THE System SHALL set Video_Element display style to "none"
4. THE System SHALL append Video_Element to document.body during extraction
5. WHEN extraction completes or fails THEN THE System SHALL remove Video_Element from document.body
6. THE System SHALL NOT play or autoplay the video during metadata extraction

### Requirement 12: isSupported Method Implementation

**User Story:** As a Flutter web developer, I want to check if a video URL is supported before attempting full metadata extraction, so that I can validate videos without throwing exceptions.

#### Acceptance Criteria

1. THE System SHALL provide isSupported method accepting URL string
2. WHEN isSupported is called THEN THE System SHALL attempt to extract metadata using getInfo
3. WHEN metadata extraction succeeds and width > 0 and height > 0 THEN THE System SHALL return true
4. WHEN metadata extraction fails or dimensions are invalid THEN THE System SHALL return false
5. THE System SHALL catch all exceptions in isSupported and return false instead of throwing

### Requirement 13: Parser and Serializer Requirements

**User Story:** As a Flutter plugin developer, I want robust JSON parsing and serialization, so that data is correctly transferred between JavaScript and Dart layers.

#### Acceptance Criteria

1. THE JavaScript_Layer SHALL serialize metadata objects to JSON strings using JSON.stringify
2. THE Dart_Layer SHALL parse JSON strings using jsonDecode from dart:convert
3. THE System SHALL validate that parsed JSON contains required "success" field
4. WHEN success is false THEN THE System SHALL extract error message from "error" field
5. WHEN success is true THEN THE System SHALL extract metadata from "data" field
6. THE System SHALL use SmartVideoInfo.fromJson to construct model objects from parsed data
7. FOR ALL valid SmartVideoInfo objects, serializing to JSON then parsing SHALL produce equivalent object (round-trip property)
