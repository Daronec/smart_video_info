import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_video_info/smart_video_info.dart';

/// Integration tests for real video files
/// These tests require running on an actual Android device/emulator
/// Run with: flutter test --device-id=DEVICE_ID test/integration_test.dart
void main() {
  // Skip these tests in CI or when no device is available
  final testAssetsPath = 'test/assets';
  final shouldRun = Platform.isAndroid || Platform.isIOS;

  group('Real Video Files Integration Tests', () {
    test('1280x720 AVI video', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_1280x720.avi';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.width, 1280);
      expect(info.height, 720);
      expect(info.resolution, '1280x720');
      expect(info.isLandscape, true);
      expect(info.container, 'avi');
      expect(info.codec, isNotEmpty);
      expect(info.fps, greaterThan(0));
      expect(info.duration.inMilliseconds, greaterThan(0));
    });

    test('1280x720 WebM video', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_1280x720.webm';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.width, 1280);
      expect(info.height, 720);
      expect(info.resolution, '1280x720');
      expect(info.container, anyOf('webm', 'matroska,webm'));
      expect(info.codec, anyOf('vp8', 'vp9'));
    });

    test('1920x1080 3GP video', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_1920x1080.3gp';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.width, 1920);
      expect(info.height, 1080);
      expect(info.resolution, '1920x1080');
      expect(info.container, '3gp');
      expect(info.aspectRatio, closeTo(16 / 9, 0.01));
    });

    test('2560x1440 WMV video', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_2560x1440.wmv';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.width, 2560);
      expect(info.height, 1440);
      expect(info.resolution, '2560x1440');
      expect(info.container, anyOf('asf', 'wmv'));
      expect(info.isLandscape, true);
    });

    test('640x360 MKV video', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_640x360.mkv';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.width, 640);
      expect(info.height, 360);
      expect(info.resolution, '640x360');
      expect(info.container, anyOf('matroska', 'matroska,webm'));
    });

    test('640x360 FLV video', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_640x360.flv';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.width, 640);
      expect(info.height, 360);
      expect(info.resolution, '640x360');
      expect(info.container, 'flv');
      expect(info.codec, isNotEmpty);
    });

    test('640x360 MOV video', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_640x360.mov';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.width, 640);
      expect(info.height, 360);
      expect(info.resolution, '640x360');
      expect(info.container, anyOf('mov', 'mov,mp4,m4a,3gp,3g2,mj2'));
      expect(info.codec, isNotEmpty);
    });

    test('640x360 MP4 video', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_640x360.mp4';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.width, 640);
      expect(info.height, 360);
      expect(info.resolution, '640x360');
      expect(info.container, 'mp4');
      expect(info.codec, isNotEmpty);
    });

    test('MOV QuickTime video', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_1920x1080.mov';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.container, anyOf('mov', 'mov,mp4,m4a,3gp,3g2,mj2'));
      expect(info.width, 1920);
      expect(info.height, 1080);
    });

    test('HEVC/H.265 4K video', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_3840x2160_hevc.mp4';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.codec, anyOf('hevc', 'h265'));
      expect(info.width, 3840);
      expect(info.height, 2160);
      expect(info.container, 'mp4');
    });

    test('Portrait/Vertical video', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_1080x1920.mp4';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.width, 1080);
      expect(info.height, 1920);
      expect(info.isPortrait, true);
      expect(info.isLandscape, false);
      expect(info.aspectRatio, closeTo(9 / 16, 0.01));
    });

    test('Video with rotation metadata', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_1280x720_rotated.mp4';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.rotation, anyOf(90, 180, 270));
      expect(info.width, greaterThan(0));
      expect(info.height, greaterThan(0));
    });

    test('FLV Flash Video', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_1920x1080.flv';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.container, 'flv');
      expect(info.codec, isNotEmpty);
    });

    test('Ultrawide 21:9 video', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_ultrawide_21_9.mp4';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.aspectRatio, closeTo(21 / 9, 0.1));
      expect(info.isLandscape, true);
    });

    test('Video with embedded subtitles', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_with_subtitles.mkv';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.hasSubtitles, true);
      expect(info.streamCount, greaterThanOrEqualTo(2)); // video + subtitles
    });

    test('Video with multiple audio tracks', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_multi_audio.mkv';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.hasAudio, true);
      expect(info.streamCount, greaterThanOrEqualTo(3)); // video + 2 audio
    });

    test('batch processing multiple videos', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final paths = [
        '$testAssetsPath/sample_640x360.mkv',
        '$testAssetsPath/sample_640x360.flv',
        '$testAssetsPath/sample_640x360.mov',
        '$testAssetsPath/sample_1280x720.avi',
        '$testAssetsPath/sample_1920x1080.3gp',
      ];

      final infos = await SmartVideoInfoPlugin.getBatch(paths);

      expect(infos.length, 5);
      expect(infos[0].resolution, '640x360');
      expect(infos[0].container, anyOf('matroska', 'matroska,webm'));
      expect(infos[1].resolution, '640x360');
      expect(infos[1].container, 'flv');
      expect(infos[2].resolution, '640x360');
      expect(infos[2].container, anyOf('mov', 'mov,mp4,m4a,3gp,3g2,mj2'));
      expect(infos[3].resolution, '1280x720');
      expect(infos[4].resolution, '1920x1080');
    });

    test('isSupported returns true for valid video', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_1280x720.avi';
      final supported = await SmartVideoInfoPlugin.isSupported(path);

      expect(supported, true);
    });

    test('handles non-existent file gracefully', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/non_existent_video.mp4';

      expect(
        () => SmartVideoInfoPlugin.getInfo(path),
        throwsA(isA<SmartVideoInfoException>()),
      );
    });

    test('handles timeout parameter', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_1280x720.avi';
      final info = await SmartVideoInfoPlugin.getInfo(
        path,
        timeout: const Duration(seconds: 10),
      );

      expect(info.width, 1280);
      expect(info.height, 720);
    });

    test('audio properties are detected', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_1280x720.avi';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      // Most sample videos have audio
      if (info.hasAudio) {
        expect(info.audioCodec, isNotNull);
        expect(info.sampleRate, greaterThan(0));
        expect(info.channels, greaterThan(0));
      }
    });

    test('stream count is accurate', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_1280x720.avi';
      final info = await SmartVideoInfoPlugin.getInfo(path);

      expect(info.streamCount, greaterThanOrEqualTo(1));
      // Video + audio = at least 2 streams if audio present
      if (info.hasAudio) {
        expect(info.streamCount, greaterThanOrEqualTo(2));
      }
    });
  });

  group('Performance Tests', () {
    test('extraction completes in reasonable time', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final path = '$testAssetsPath/sample_1280x720.avi';
      final stopwatch = Stopwatch()..start();

      await SmartVideoInfoPlugin.getInfo(path);

      stopwatch.stop();
      // Should complete in less than 100ms for small files
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('batch processing is efficient', () async {
      if (!shouldRun) {
        markTestSkipped('Requires Android/iOS device');
        return;
      }

      final paths = [
        '$testAssetsPath/sample_640x360.mkv',
        '$testAssetsPath/sample_640x360.flv',
        '$testAssetsPath/sample_640x360.mov',
        '$testAssetsPath/sample_1280x720.avi',
        '$testAssetsPath/sample_1920x1080.3gp',
      ];

      final stopwatch = Stopwatch()..start();
      await SmartVideoInfoPlugin.getBatch(paths);
      stopwatch.stop();

      // Batch should complete in reasonable time (5 files)
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });
  });
}
