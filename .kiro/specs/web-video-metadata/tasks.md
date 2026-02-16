# Implementation Plan: Web Video Metadata Extraction

## Overview

This implementation plan breaks down the web platform support into discrete coding tasks. The implementation consists of two main layers: JavaScript implementation (web/smart_video_info.js) for HTML5 Video API interaction, and Dart bridge layer (lib/src/smart_video_info_web.dart) for Flutter integration. Tasks are ordered to build incrementally, with testing integrated throughout to catch errors early.

## Tasks

- [ ] 1. Implement JavaScript core metadata extraction
  - [ ] 1.1 Create SmartVideoInfoWeb class in web/smart_video_info.js
    - Implement class constructor
    - Expose class on window object
    - _Requirements: 1.1, 1.2_

  - [ ] 1.2 Implement extractMetadata method
    - Extract width and height from videoWidth/videoHeight
    - Calculate duration in milliseconds
    - Extract container from URL extension
    - Detect codec from URL patterns (.mp4→h264, .webm→vp8, .ogv→theora)
    - Set web platform defaults (bitrate=0, fps=30.0, rotation=0)
    - Detect hasAudio using mozHasAudio, webkitAudioDecodedByteCount, audioTracks
    - Detect hasSubtitles from textTracks
    - Calculate streamCount (1 + audio tracks)
    - Add audio metadata when hasAudio is true (audioCodec="unknown", sampleRate=44100, channels=2)
    - Return metadata object matching JSON Schema v1
    - _Requirements: 3.1, 3.2, 3.3, 3.5, 3.6, 3.7, 3.8, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 5.1, 5.2, 5.3, 5.4_

  - [ ]\* 1.3 Write property test for extractMetadata
    - **Property 4: Dimension extraction accuracy**
    - **Property 5: Duration conversion accuracy**
    - **Property 6: Container extraction from URL**
    - **Property 7: Stream count calculation**
    - **Property 8: Codec detection from URL patterns**
    - **Property 9: Web platform default values**
    - **Property 10: Audio metadata defaults when audio present**
    - **Property 11: Audio metadata null when audio absent**
    - **Validates: Requirements 3.1, 3.2, 3.3, 3.5, 3.8, 4.1-4.7, 5.1-5.4**

- [ ] 2. Implement JavaScript getInfo method with error handling
  - [ ] 2.1 Implement URL validation
    - Check URL starts with http://, https://, or blob:
    - Reject invalid URLs with error message
    - _Requirements: 2.1, 2.2_

  - [ ] 2.2 Implement video element creation and configuration
    - Create video element with preload='metadata', muted=true, display='none'
    - Append to document.body
    - Set up timeout handler (10 seconds)
    - Register loadedmetadata and error event listeners
    - Set video.src to URL
    - Return Promise
    - _Requirements: 2.3, 2.4, 2.5, 11.1, 11.2, 11.3, 11.4_

  - [ ] 2.3 Implement success and error handlers
    - On loadedmetadata: clear timeout, call extractMetadata, remove video element, resolve with {success: true, data}
    - On error: clear timeout, remove video element, reject with {success: false, error}
    - On timeout: remove video element, reject with timeout error
    - Ensure video element is always removed from DOM
    - _Requirements: 2.6, 6.1, 6.3, 6.6, 7.1, 7.2, 7.3, 7.5_

  - [ ]\* 2.4 Write property tests for getInfo
    - **Property 1: Valid URL acceptance**
    - **Property 2: Invalid URL rejection**
    - **Property 3: Video element cleanup**
    - **Property 12: Video load error handling**
    - **Property 13: Exception conversion to rejection**
    - **Property 14: Error response format**
    - **Property 24: No video playback during extraction**
    - **Validates: Requirements 2.1, 2.2, 2.6, 6.1, 6.3, 6.6, 11.6**

  - [ ]\* 2.5 Write unit tests for error cases
    - Test invalid URL formats
    - Test video element cleanup on success and failure
    - Test timeout behavior (using fake timers)
    - _Requirements: 2.2, 2.6, 7.1, 7.2_

- [ ] 3. Checkpoint - Ensure JavaScript tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 4. Implement JavaScript getBatch method
  - [ ] 4.1 Implement sequential batch processing
    - Accept array of URLs
    - Return empty array for empty input
    - Process URLs sequentially using getInfo
    - Stringify each result
    - Fail fast on first error
    - Return array of JSON strings in same order
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_

  - [ ]\* 4.2 Write property tests for getBatch
    - **Property 15: Batch order preservation**
    - **Property 16: Batch failure propagation**
    - **Property 17: Batch success consistency**
    - **Validates: Requirements 8.4, 8.5, 8.6**

  - [ ]\* 4.3 Write unit test for empty batch
    - Test getBatch with empty array returns empty array
    - _Requirements: 8.2_

- [ ] 5. Implement Dart bridge layer
  - [ ] 5.1 Update lib/src/smart_video_info_web.dart with dart:js integration
    - Import dart:js library
    - Import dart:html for conditional compilation
    - Keep existing SmartVideoInfoWeb class structure
    - _Requirements: 10.1_

  - [ ] 5.2 Implement getInfo method with JavaScript bridge
    - Get SmartVideoInfoWeb constructor from window using context['SmartVideoInfoWeb']
    - Instantiate JS object using JsObject(constructor)
    - Call getInfo method using jsObject.callMethod('getInfo', [path])
    - Convert Promise to Future using promiseToFuture
    - Parse JSON response using jsonDecode
    - Validate success field
    - Extract data or error from response
    - Create SmartVideoInfo.fromJson on success
    - Throw SmartVideoInfoException on failure
    - Apply timeout wrapper (10 seconds)
    - _Requirements: 10.2, 10.3, 10.4, 10.5, 13.2, 13.3, 13.4, 13.5, 13.6_

  - [ ] 5.3 Implement getBatch method with JavaScript bridge
    - Return empty list for empty paths
    - Instantiate JS SmartVideoInfoWeb object
    - Call getBatch method using jsObject.callMethod('getBatch', [paths])
    - Convert Promise to Future
    - Parse each JSON string in results
    - Validate success field for each
    - Create SmartVideoInfo objects
    - Apply timeout wrapper (30 seconds)
    - _Requirements: 10.2, 10.3, 10.4, 13.2, 13.5, 13.6_

  - [ ] 5.4 Implement isSupported method
    - Call getInfo(path) in try-catch
    - Return true if succeeds and width > 0 and height > 0
    - Return false on any exception (don't propagate)
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

  - [ ]\* 5.5 Write property tests for Dart bridge
    - **Property 23: JavaScript exception conversion**
    - **Property 25: isSupported returns true for valid videos**
    - **Property 26: isSupported returns false for invalid videos**
    - **Property 27: isSupported exception suppression**
    - **Validates: Requirements 10.5, 12.3, 12.4, 12.5**

- [ ] 6. Implement JSON schema compliance validation
  - [ ] 6.1 Add JSON structure validation in Dart layer
    - Validate success field presence
    - Validate data object structure on success
    - Validate error field on failure
    - Validate all required fields in data object
    - Validate conditional audio fields based on hasAudio
    - Validate numeric field types
    - Validate duration is integer in milliseconds
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8_

  - [ ]\* 6.2 Write property tests for JSON schema compliance
    - **Property 18: Success field presence**
    - **Property 19: Success response structure**
    - **Property 20: Conditional audio fields**
    - **Property 21: Numeric field types**
    - **Property 22: Duration format**
    - **Property 28: JSON serialization round-trip**
    - **Validates: Requirements 9.1, 9.2, 9.4, 9.5, 9.6, 9.7, 9.8, 13.7**

- [ ] 7. Update plugin routing to use web implementation
  - [ ] 7.1 Update lib/src/smart_video_info_plugin.dart
    - Ensure kIsWeb check routes to SmartVideoInfoWeb
    - Verify getInfo, getBatch, and isSupported all route correctly
    - Maintain same timeout defaults
    - _Requirements: 10.6, 10.7_

  - [ ]\* 7.2 Write integration test for platform routing
    - Test that kIsWeb routes to web implementation
    - _Requirements: 10.7_

- [ ] 8. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Create example and documentation
  - [ ] 9.1 Update example app to demonstrate web platform
    - Add web platform example usage
    - Show URL-based video loading
    - Demonstrate error handling for CORS and invalid URLs
    - Show batch processing example

  - [ ] 9.2 Update README with web platform information
    - Document web platform support
    - Explain URL-only limitation
    - Document HTML5 API limitations (estimated codec, default fps, etc.)
    - Provide CORS guidance
    - Add web platform to supported platforms list

  - [ ] 9.3 Add inline documentation to web implementation
    - Document SmartVideoInfoWeb class and methods
    - Document URL validation requirements
    - Document timeout behavior
    - Document JSON schema format

- [ ] 10. Final checkpoint - Verify complete integration
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties across many generated inputs
- Unit tests validate specific examples and edge cases
- JavaScript implementation uses HTML5 Video API (no external dependencies)
- Dart implementation uses dart:js for JavaScript interop
- Web platform has inherent limitations: URL-only, estimated codec/fps, no rotation detection
- All platforms share the same JSON Schema v1 format for consistency
