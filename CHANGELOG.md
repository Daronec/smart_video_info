## 1.2.1

- Add macOS support with native AVFoundation
- Add Web platform support with HTML5 Video API
- Fixed web audio detection using canplay event and preload=auto
- Cross-platform support: Android + iOS + macOS + Windows + Web
- Updated README with web platform usage examples
- Comprehensive test coverage for all platforms

## 1.2.0

- Add Windows support with native Media Foundation API
- Cross-platform support: Android + iOS + Windows
- No external dependencies on Windows (uses system Media Foundation)
- Consistent API across all platforms

## 1.1.0

- Add iOS support with native AVFoundation
- Cross-platform support: Android + iOS
- Consistent API across both platforms
- No external dependencies on iOS (uses system AVFoundation)

## 1.0.0

- Initial release
- Android support with native FFmpeg API integration
- Ultra-fast metadata extraction (<20ms average)
- Single file and batch processing support
- Zero subprocess overhead - direct native API access
- Comprehensive video metadata extraction (codec, resolution, duration, fps, bitrate, rotation, audio info)
