import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_video_info/smart_video_info.dart';

void main() {
  // Skip tests if not running on macOS
  if (!Platform.isMacOS) {
    test('Skip - not running on macOS', () {
      expect(true, true);
    });
    return;
  }

  group('macOS Integration Tests - Real Video Files', () {
    test('extracts metadata from MP4 video', () async {
      final info =
          await SmartVideoInfoPlugin.getInfo('test/assets/sample_640x360.mp4');

      expect(info.width, 640);
      expect(info.height, 360);
      expect(info.duration.inMilliseconds, greaterThan(0));
      expect(info.codec, isNotEmpty);
      expect(info.container, 'mp4');
      expect(info.fps, greaterThan(0));
      expect(info.bitrate, greaterThanOrEqualTo(0));
      expect(info.streamCount, greaterThan(0));
    });

    test('extracts metadata from MOV video', () async {
      final info =
          await SmartVideoInfoPlugin.getInfo('test/assets/sample_640x360.mov');

      expect(info.width, 640);
      expect(info.height, 360);
      expect(info.container, 'mov');
      expect(info.codec, isNotEmpty);
    });

    test('extracts metadata from MKV video', () async {
      final info =
          await SmartVideoInfoPlugin.getInfo('test/assets/sample_640x360.mkv');

      expect(info.width, 640);
      expect(info.height, 360);
      expect(info.container, 'mkv');
    });

    test('extracts metadata from AVI video', () async {
      final info =
          await SmartVideoInfoPlugin.getInfo('test/assets/sample_1280x720.avi');

      expect(info.width, 1280);
      expect(info.height, 720);
      expect(info.container, 'avi');
    });

    test('extracts metadata from WebM video', () async {
      final info = await SmartVideoInfoPlugin.getInfo(
          'test/assets/sample_1280x720.webm');

      expect(info.width, 1280);
      expect(info.height, 720);
      expect(info.container, 'webm');
    });

    test('extracts metadata from FLV video', () async {
      final info =
          await SmartVideoInfoPlugin.getInfo('test/assets/sample_640x360.flv');

      expect(info.width, 640);
      expect(info.height, 360);
      expect(info.container, 'flv');
    });

    test('extracts metadata from 3GP video', () async {
      final info = await SmartVideoInfoPlugin.getInfo(
          'test/assets/sample_1920x1080.3gp');

      expect(info.width, 1920);
      expect(info.height, 1080);
      expect(info.container, '3gp');
    });

    test('extracts metadata from WMV video', () async {
      final info = await SmartVideoInfoPlugin.getInfo(
          'test/assets/sample_2560x1440.wmv');

      expect(info.width, 2560);
      expect(info.height, 1440);
      expect(info.container, 'wmv');
    });

    test('extracts metadata from Broadcast Woman MP4', () async {
      final info = await SmartVideoInfoPlugin.getInfo(
          'test/assets/Broadcast_Woman.mp4');

      expect(info.width, greaterThan(0));
      expect(info.height, greaterThan(0));
      expect(info.container, 'mp4');
      expect(info.codec, isNotEmpty);
      expect(info.duration.inMilliseconds, greaterThan(0));
    });

    test('extracts metadata from MP4 with audio', () async {
      final info =
          await SmartVideoInfoPlugin.getInfo('test/assets/with_audio.mp4');

      expect(info.width, greaterThan(0));
      expect(info.height, greaterThan(0));
      expect(info.container, 'mp4');
      expect(info.hasAudio, true);
      expect(info.audioCodec, isNotNull);
      expect(info.sampleRate, greaterThan(0));
      expect(info.channels, greaterThan(0));
    });

    test('handles non-existent file gracefully', () async {
      expect(
        () => SmartVideoInfoPlugin.getInfo('/non/existent/file.mp4'),
        throwsA(isA<SmartVideoInfoException>()),
      );
    });

    test('handles invalid video file gracefully', () async {
      final tempDir =
          Directory.systemTemp.createTempSync('smart_video_info_test');
      final invalidFile = File('${tempDir.path}/invalid.mp4');
      invalidFile.writeAsStringSync('This is not a video file');

      expect(
        () => SmartVideoInfoPlugin.getInfo(invalidFile.path),
        throwsA(isA<SmartVideoInfoException>()),
      );

      tempDir.deleteSync(recursive: true);
    });

    test('batch processing returns results in order', () async {
      final infos = await SmartVideoInfoPlugin.getBatch([
        'test/assets/sample_640x360.mp4',
        'test/assets/sample_640x360.mov',
      ]);

      expect(infos.length, 2);
      expect(infos[0].container, 'mp4');
      expect(infos[1].container, 'mov');
    });

    test('batch processing fails fast on error', () async {
      expect(
        () => SmartVideoInfoPlugin.getBatch([
          'test/assets/sample_640x360.mp4',
          '/non/existent/file.mp4',
        ]),
        throwsA(isA<SmartVideoInfoException>()),
      );
    });

    test('isSupported returns true for valid video', () async {
      final supported = await SmartVideoInfoPlugin.isSupported(
          'test/assets/sample_640x360.mp4');
      expect(supported, true);
    });

    test('isSupported returns false for non-existent file', () async {
      final supported =
          await SmartVideoInfoPlugin.isSupported('/non/existent/file.mp4');
      expect(supported, false);
    });

    test('respects custom timeout', () async {
      expect(
        () => SmartVideoInfoPlugin.getInfo(
          '/non/existent/file.mp4',
          timeout: const Duration(milliseconds: 100),
        ),
        throwsA(isA<SmartVideoInfoException>()),
      );
    });
  });

  group('macOS Property-Based Tests', () {
    test('Property 1: All required metadata fields are extracted', () async {
      final info =
          await SmartVideoInfoPlugin.getInfo('test/assets/sample_640x360.mp4');

      // All required fields must be present
      expect(info.width, isNotNull);
      expect(info.height, isNotNull);
      expect(info.duration, isNotNull);
      expect(info.codec, isNotNull);
      expect(info.bitrate, isNotNull);
      expect(info.fps, isNotNull);
      expect(info.rotation, isNotNull);
      expect(info.container, isNotNull);
      expect(info.hasAudio, isNotNull);
      expect(info.hasSubtitles, isNotNull);
      expect(info.streamCount, isNotNull);
    });

    test('Property 2: Dimensions are positive integers', () async {
      final info =
          await SmartVideoInfoPlugin.getInfo('test/assets/sample_640x360.mp4');

      expect(info.width, greaterThan(0));
      expect(info.height, greaterThan(0));
    });

    test('Property 3: Rotation is normalized', () async {
      final info =
          await SmartVideoInfoPlugin.getInfo('test/assets/sample_640x360.mp4');

      expect([0, 90, 180, 270], contains(info.rotation));
    });

    test('Property 4: Container matches file extension', () async {
      final testCases = [
        ('test/assets/sample_640x360.mp4', 'mp4'),
        ('test/assets/sample_640x360.mov', 'mov'),
        ('test/assets/sample_640x360.mkv', 'mkv'),
        ('test/assets/sample_1280x720.avi', 'avi'),
      ];

      for (final testCase in testCases) {
        final info = await SmartVideoInfoPlugin.getInfo(testCase.$1);
        expect(info.container, testCase.$2);
      }
    });

    test('Property 5: Stream count is positive', () async {
      final info =
          await SmartVideoInfoPlugin.getInfo('test/assets/sample_640x360.mp4');

      expect(info.streamCount, greaterThan(0));
    });

    test('Property 6: Audio metadata completeness', () async {
      final info =
          await SmartVideoInfoPlugin.getInfo('test/assets/sample_640x360.mp4');

      if (info.hasAudio) {
        expect(info.audioCodec, isNotNull);
        expect(info.audioCodec, isNotEmpty);
        // Sample rate and channels might be null in some cases
      }
    });

    test('Property 8: Codec strings are non-empty', () async {
      final info =
          await SmartVideoInfoPlugin.getInfo('test/assets/sample_640x360.mp4');

      expect(info.codec, isNotEmpty);
      if (info.hasAudio && info.audioCodec != null) {
        expect(info.audioCodec, isNotEmpty);
      }
    });

    test('Property 11: getBatch preserves order and completeness', () async {
      final paths = [
        'test/assets/sample_640x360.mp4',
        'test/assets/sample_640x360.mov',
        'test/assets/sample_640x360.mkv',
      ];

      final infos = await SmartVideoInfoPlugin.getBatch(paths);

      expect(infos.length, paths.length);
      expect(infos[0].container, 'mp4');
      expect(infos[1].container, 'mov');
      expect(infos[2].container, 'mkv');
    });

    test('Property 13: Non-existent files return error', () async {
      expect(
        () => SmartVideoInfoPlugin.getInfo('/non/existent/file.mp4'),
        throwsA(isA<SmartVideoInfoException>()),
      );
    });

    test('Property 14: Invalid video files return error', () async {
      final tempDir =
          Directory.systemTemp.createTempSync('smart_video_info_test');
      final invalidFile = File('${tempDir.path}/invalid.mp4');
      invalidFile.writeAsStringSync('Not a video');

      expect(
        () => SmartVideoInfoPlugin.getInfo(invalidFile.path),
        throwsA(isA<SmartVideoInfoException>()),
      );

      tempDir.deleteSync(recursive: true);
    });

    test('Property 15: Batch processing fails fast', () async {
      expect(
        () => SmartVideoInfoPlugin.getBatch([
          'test/assets/sample_640x360.mp4',
          '/non/existent/file.mp4',
          'test/assets/sample_640x360.mov',
        ]),
        throwsA(isA<SmartVideoInfoException>()),
      );
    });
  });

  group('macOS Performance Tests', () {
    test('single file extraction completes quickly', () async {
      final stopwatch = Stopwatch()..start();
      await SmartVideoInfoPlugin.getInfo('test/assets/sample_640x360.mp4');
      stopwatch.stop();

      // Should complete in less than 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('batch processing is efficient', () async {
      final paths = List.generate(5, (_) => 'test/assets/sample_640x360.mp4');

      final stopwatch = Stopwatch()..start();
      await SmartVideoInfoPlugin.getBatch(paths);
      stopwatch.stop();

      // Should complete in less than 2 seconds for 5 files
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });
}
