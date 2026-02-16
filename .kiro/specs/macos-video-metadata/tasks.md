# Implementation Plan: macOS Video Metadata Extraction

## Overview

This implementation plan breaks down the macOS platform support into discrete coding tasks. The approach mirrors the existing iOS implementation, leveraging AVFoundation for metadata extraction. Tasks are organized to build incrementally, with testing integrated throughout to catch errors early.

## Tasks

- [x] 1. Set up macOS plugin structure and CocoaPods configuration
  - Create `macos/` directory with proper Flutter plugin structure
  - Create `macos/Classes/` directory for Swift source files
  - Create `macos/smart_video_info.podspec` with macOS platform configuration
  - Configure minimum macOS version (10.14), Swift version (5.0), and FlutterMacOS dependency
  - _Requirements: 1.1, 1.2, 1.5_

- [x] 2. Implement core plugin class and method channel registration
  - [x] 2.1 Create `SmartVideoInfoPlugin.swift` with plugin registration
    - Implement `FlutterPlugin` protocol
    - Register with Flutter plugin registrar
    - Set up MethodChannel with name "smart_video_info"
    - _Requirements: 1.1, 1.3, 1.4_
  - [ ]\* 2.2 Write unit test for plugin registration
    - Verify plugin responds to method channel calls
    - **Property 10: getInfo extracts metadata**
    - **Validates: Requirements 3.1**

- [x] 3. Implement method channel handler
  - [x] 3.1 Create `handle(_:result:)` method with method routing
    - Handle "getInfo" method with path argument validation
    - Handle "getBatch" method with paths argument validation
    - Return `FlutterMethodNotImplemented` for unsupported methods
    - Return `FlutterError` with code "INVALID_ARGUMENT" for invalid arguments
    - _Requirements: 3.1, 3.2, 3.3, 3.4_
  - [ ]\* 3.2 Write unit tests for method routing
    - Test unsupported method returns FlutterMethodNotImplemented
    - **Property 12: Invalid arguments return error**
    - **Validates: Requirements 3.4**

- [x] 4. Implement single file metadata extraction with background threading
  - [x] 4.1 Create `getVideoMetadata(path:result:)` method
    - Dispatch to background thread with QoS `.userInitiated`
    - Call `extractMetadata(path:)` and handle errors
    - Return result on main thread using `DispatchQueue.main.async`
    - Return `FlutterError` with code "METADATA_ERROR" on failure
    - _Requirements: 5.1, 5.2, 5.4, 6.5_
  - [ ]\* 4.2 Write property test for background processing
    - **Property 18: Concurrent calls are safe**
    - **Validates: Requirements 12.1**

- [x] 5. Implement core metadata extraction logic
  - [x] 5.1 Create `extractMetadata(path:)` method - video track loading
    - Create URL from file path
    - Load AVAsset from URL
    - Load video tracks using `asset.loadTracks(withMediaType: .video)`
    - Throw error "No video track found" if no video track exists
    - _Requirements: 2.1, 2.2, 6.3_
  - [x] 5.2 Implement video dimension extraction
    - Get natural size from video track
    - Apply preferred transform to handle rotation
    - Use absolute values for width and height
    - Convert to integer pixel values
    - _Requirements: 2.1, 2.2, 13.1, 13.2, 13.3_
  - [x] 5.3 Implement video properties extraction
    - Extract frame rate using `nominalFrameRate`
    - Extract duration in milliseconds using `CMTimeGetSeconds`
    - Extract bitrate using `estimatedDataRate`
    - _Requirements: 2.3, 2.5, 2.6_
  - [x] 5.4 Implement video codec extraction
    - Get format descriptions from video track
    - Extract FourCC code using `CMFormatDescriptionGetMediaSubType`
    - Convert FourCC to string using `fourCCToString` helper
    - _Requirements: 2.4, 8.1, 8.3, 8.4_
  - [ ]\* 5.5 Write property tests for core metadata extraction
    - **Property 1: All required metadata fields are extracted**
    - **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.12, 2.13, 2.14**
    - **Property 2: Dimensions are positive integers**
    - **Validates: Requirements 13.2, 13.3**
    - **Property 5: Stream count is positive**
    - **Validates: Requirements 2.14**

- [x] 6. Implement rotation calculation
  - [x] 6.1 Create `getRotationFromTransform(_:)` helper method
    - Calculate angle from transform matrix using `atan2`
    - Convert radians to degrees
    - Normalize to 0, 90, 180, or 270 using switch statement
    - Handle ranges: 85-95 → 90, 175-185/-185-(-175) → 180, -95-(-85) → 270, else → 0
    - _Requirements: 2.7, 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_
  - [ ]\* 6.2 Write property test for rotation normalization
    - **Property 3: Rotation is normalized**
    - **Validates: Requirements 2.7, 9.2**

- [x] 7. Implement audio metadata extraction
  - [x] 7.1 Create audio track detection and extraction logic
    - Load audio tracks using `asset.loadTracks(withMediaType: .audio)`
    - Set `hasAudio` based on whether audio tracks exist
    - Extract audio codec FourCC from first audio track
    - Extract sample rate from `AudioStreamBasicDescription`
    - Extract channel count from `AudioStreamBasicDescription`
    - _Requirements: 2.9, 2.10, 2.11, 2.12, 8.2_
  - [ ]\* 7.2 Write property tests for audio metadata
    - **Property 6: Audio metadata completeness**
    - **Validates: Requirements 2.9, 2.10, 2.11, 2.12, 4.4**
    - **Property 7: Audio metadata absence**
    - **Validates: Requirements 2.12, 4.5**
    - **Property 8: Codec strings are non-empty**
    - **Validates: Requirements 2.4, 8.1, 8.2**

- [x] 8. Implement subtitle detection and container format extraction
  - [x] 8.1 Add subtitle track detection
    - Load subtitle tracks using `asset.loadTracks(withMediaType: .subtitle)`
    - Set `hasSubtitles` based on whether subtitle tracks exist
    - _Requirements: 2.13_
  - [x] 8.2 Add container format extraction
    - Extract file extension from URL path
    - Convert to lowercase
    - _Requirements: 2.8_
  - [x] 8.3 Add stream count calculation
    - Count total tracks using `asset.tracks.count`
    - _Requirements: 2.14_
  - [ ]\* 8.4 Write property tests for additional metadata
    - **Property 4: Container matches file extension**
    - **Validates: Requirements 2.8**

- [x] 9. Implement JSON response building
  - [x] 9.1 Create JSON response structure
    - Build data dictionary with all metadata fields
    - Use `compactMapValues` to remove nil optional fields
    - Wrap in success response with "success": true
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_
  - [x] 9.2 Create `jsonToString(_:)` helper method
    - Serialize dictionary using `JSONSerialization`
    - Convert data to UTF-8 string
    - Throw error if encoding fails
    - _Requirements: 4.6, 6.4_
  - [ ]\* 9.3 Write property test for JSON schema compliance
    - **Property 9: JSON schema compliance**
    - **Validates: Requirements 4.1, 4.2, 4.3, 4.6**

- [x] 10. Implement FourCC codec conversion helper
  - [x] 10.1 Create `fourCCToString(_:)` helper method
    - Extract 4 bytes from FourCharCode
    - Convert to C string array
    - Create Swift String and trim whitespace
    - _Requirements: 8.1, 8.2_

- [ ] 11. Checkpoint - Test single file extraction
  - Ensure all tests pass for single file metadata extraction
  - Test with various video formats from test assets
  - Verify error handling for invalid files
  - Ask the user if questions arise

- [x] 12. Implement batch metadata extraction
  - [x] 12.1 Create `getBatchMetadata(paths:result:)` method
    - Dispatch to background thread with QoS `.userInitiated`
    - Iterate through paths array
    - Call `extractMetadata(path:)` for each path
    - Collect results in array
    - Return on first error (fail-fast)
    - Return results array on main thread
    - _Requirements: 3.2, 5.3, 6.6, 10.1, 10.2, 10.3, 10.4_
  - [ ]\* 12.2 Write property tests for batch processing
    - **Property 11: getBatch preserves order and completeness**
    - **Validates: Requirements 3.2, 10.2, 10.3**
    - **Property 15: Batch processing fails fast**
    - **Validates: Requirements 6.6**

- [x] 13. Implement comprehensive error handling
  - [x] 13.1 Add error handling for file not found
    - Catch file system errors
    - Return descriptive error message
    - _Requirements: 6.1, 6.5_
  - [x] 13.2 Add error handling for invalid video files
    - Catch AVFoundation loading errors
    - Return descriptive error message
    - _Requirements: 6.2, 6.5_
  - [ ]\* 13.3 Write property tests for error handling
    - **Property 13: Non-existent files return error**
    - **Validates: Requirements 6.1, 6.5**
    - **Property 14: Invalid video files return error**
    - **Validates: Requirements 6.2, 6.5**

- [x] 14. Create macOS integration tests
  - [ ]\* 14.1 Create `test/macos_integration_test.dart`
    - Copy structure from existing `integration_test.dart`
    - Adapt tests for macOS platform detection
    - Test all video formats from test assets
    - Test portrait/landscape videos
    - Test videos with/without audio
    - Test videos with subtitles
    - Test rotated videos
    - Test HEVC/H.265 videos
    - **Property 16: Common video formats are supported**
    - **Validates: Requirements 7.1-7.9**
    - **Property 17: AVFoundation-compatible formats are handled**
    - **Validates: Requirements 7.10**
  - [ ]\* 14.2 Add performance tests
    - Test single file extraction completes in <100ms
    - Test batch processing of 5 files completes in <500ms
    - _Requirements: Performance testing_

- [x] 15. Update plugin configuration files
  - [x] 15.1 Update `pubspec.yaml` to include macOS platform
    - Add macOS to supported platforms
    - Update plugin configuration
  - [x] 15.2 Update README.md
    - Add macOS to supported platforms list
    - Update architecture documentation
    - Add macOS-specific notes if needed

- [ ] 16. Final checkpoint - Complete integration testing
  - Run all tests on macOS device/simulator
  - Verify no regressions in existing platforms
  - Test concurrent method calls
  - Test memory usage with repeated extractions
  - Ensure all property tests pass with 100+ iterations
  - Ask the user if questions arise

## Notes

- Tasks marked with `*` are optional testing tasks and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties with 100+ iterations
- Unit tests validate specific examples and edge cases
- The implementation closely mirrors the iOS implementation for consistency
- All metadata extraction occurs on background threads to prevent UI blocking
- Error handling uses Flutter's standard error mechanisms
