import 'package:flutter_test/flutter_test.dart';
import 'package:smart_video_info/smart_video_info.dart';

void main() {
  group('SmartVideoInfo', () {
    test('fromJson parses correctly', () {
      final json = {
        'width': 1920,
        'height': 1080,
        'duration': 120000,
        'codec': 'h264',
        'bitrate': 5000000,
        'fps': 30.0,
        'rotation': 0,
        'container': 'mp4',
        'audioCodec': 'aac',
        'sampleRate': 44100,
        'channels': 2,
        'hasAudio': true,
        'hasSubtitles': false,
        'streamCount': 2,
      };

      final info = SmartVideoInfo.fromJson(json);

      expect(info.width, 1920);
      expect(info.height, 1080);
      expect(info.duration, const Duration(milliseconds: 120000));
      expect(info.codec, 'h264');
      expect(info.bitrate, 5000000);
      expect(info.fps, 30.0);
      expect(info.rotation, 0);
      expect(info.container, 'mp4');
      expect(info.audioCodec, 'aac');
      expect(info.sampleRate, 44100);
      expect(info.channels, 2);
      expect(info.hasAudio, true);
      expect(info.hasSubtitles, false);
      expect(info.streamCount, 2);
    });

    test('computed properties work correctly', () {
      final landscape = SmartVideoInfo.fromJson({
        'width': 1920,
        'height': 1080,
        'duration': 1000,
        'codec': 'h264',
        'bitrate': 0,
        'fps': 30.0,
        'rotation': 0,
        'container': 'mp4',
        'hasAudio': false,
        'hasSubtitles': false,
        'streamCount': 1,
      });

      expect(landscape.isLandscape, true);
      expect(landscape.isPortrait, false);
      expect(landscape.resolution, '1920x1080');
      expect(landscape.aspectRatio, closeTo(1.78, 0.01));

      final portrait = SmartVideoInfo.fromJson({
        'width': 1080,
        'height': 1920,
        'duration': 1000,
        'codec': 'h264',
        'bitrate': 0,
        'fps': 30.0,
        'rotation': 0,
        'container': 'mp4',
        'hasAudio': false,
        'hasSubtitles': false,
        'streamCount': 1,
      });

      expect(portrait.isLandscape, false);
      expect(portrait.isPortrait, true);
    });

    test('handles null optional fields', () {
      final json = {
        'width': 1920,
        'height': 1080,
        'duration': 1000,
        'codec': 'h264',
        'bitrate': 0,
        'fps': 30.0,
        'rotation': 0,
        'container': 'mp4',
        'hasAudio': false,
        'hasSubtitles': false,
        'streamCount': 1,
      };

      final info = SmartVideoInfo.fromJson(json);

      expect(info.audioCodec, isNull);
      expect(info.sampleRate, isNull);
      expect(info.channels, isNull);
    });

    test('throws FormatException on missing required fields', () {
      expect(
        () => SmartVideoInfo.fromJson({'height': 1080}),
        throwsFormatException,
      );
      expect(
        () => SmartVideoInfo.fromJson({'width': 1920}),
        throwsFormatException,
      );
      expect(
        () => SmartVideoInfo.fromJson({}),
        throwsFormatException,
      );
    });

    test('toString returns readable format', () {
      final info = SmartVideoInfo.fromJson({
        'width': 1920,
        'height': 1080,
        'duration': 120000,
        'codec': 'h264',
        'bitrate': 0,
        'fps': 30.0,
        'rotation': 0,
        'container': 'mp4',
        'hasAudio': true,
        'hasSubtitles': false,
        'streamCount': 2,
      });

      expect(info.toString(), contains('1920x1080'));
      expect(info.toString(), contains('h264'));
    });
  });

  group('SmartVideoInfoException', () {
    test('formats message correctly', () {
      final exception = SmartVideoInfoException('Test error', 'TEST_CODE');
      expect(exception.toString(), contains('Test error'));
      expect(exception.code, 'TEST_CODE');
    });
  });
}
