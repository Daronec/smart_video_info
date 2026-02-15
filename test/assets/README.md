# Test Video Assets

This directory should contain sample video files for integration testing.

## Required Files

The integration tests expect the following video files:

| Filename                      | Format | Resolution | Purpose                            |
| ----------------------------- | ------ | ---------- | ---------------------------------- |
| `sample_640x360.mkv`          | MKV    | 640x360    | Test MKV container, low resolution |
| `sample_640x360.flv`          | FLV    | 640x360    | Test Flash Video, low resolution   |
| `sample_640x360.mov`          | MOV    | 640x360    | Test QuickTime, low resolution     |
| `sample_640x360.mp4`          | MP4    | 640x360    | Test MP4/H.264, low resolution     |
| `sample_1280x720.avi`         | AVI    | 1280x720   | Test AVI container, HD resolution  |
| `sample_1280x720.webm`        | WebM   | 1280x720   | Test WebM/VP8-VP9 codec            |
| `sample_1920x1080.3gp`        | 3GP    | 1920x1080  | Test 3GP mobile format, Full HD    |
| `sample_2560x1440.wmv`        | WMV    | 2560x1440  | Test WMV format, QHD resolution    |
| `sample_1920x1080.mov`        | MOV    | 1920x1080  | Test QuickTime format              |
| `sample_3840x2160_hevc.mp4`   | MP4    | 3840x2160  | Test H.265/HEVC codec, 4K          |
| `sample_1080x1920.mp4`        | MP4    | 1080x1920  | Test portrait/vertical video       |
| `sample_1280x720_rotated.mp4` | MP4    | 1280x720   | Test rotation metadata             |
| `sample_1920x1080.flv`        | FLV    | 1920x1080  | Test Flash Video format            |
| `sample_ultrawide_21_9.mp4`   | MP4    | 2560x1080  | Test ultrawide aspect ratio (21:9) |
| `sample_with_subtitles.mkv`   | MKV    | Any        | Test subtitle detection            |
| `sample_multi_audio.mkv`      | MKV    | Any        | Test multiple audio tracks         |

## Why These Files Are Not in Git

Video files are excluded from version control because:

- They are large (several MB each)
- They would bloat the repository
- They can be easily obtained from public sources

## How to Obtain Test Videos

### Option 1: Use Your Own Videos

Any video files will work for basic testing. Just rename them to match the expected filenames.

### Option 2: Download Sample Videos

Free sample videos are available from:

- [Sample Videos](https://sample-videos.com/)
- [Pexels Videos](https://www.pexels.com/videos/)
- [Pixabay Videos](https://pixabay.com/videos/)

### Option 3: Generate Test Videos with FFmpeg

```bash
# 640x360 MKV
ffmpeg -f lavfi -i testsrc=duration=10:size=640x360:rate=30 -c:v libx264 sample_640x360.mkv

# 640x360 FLV
ffmpeg -f lavfi -i testsrc=duration=10:size=640x360:rate=30 -c:v flv sample_640x360.flv

# 640x360 MOV
ffmpeg -f lavfi -i testsrc=duration=10:size=640x360:rate=30 -c:v libx264 sample_640x360.mov

# 640x360 MP4
ffmpeg -f lavfi -i testsrc=duration=10:size=640x360:rate=30 -c:v libx264 sample_640x360.mp4

# 1280x720 AVI
ffmpeg -f lavfi -i testsrc=duration=10:size=1280x720:rate=30 -c:v mpeg4 sample_1280x720.avi

# 1280x720 WebM
ffmpeg -f lavfi -i testsrc=duration=10:size=1280x720:rate=30 -c:v libvpx sample_1280x720.webm

# 1920x1080 3GP
ffmpeg -f lavfi -i testsrc=duration=10:size=1920x1080:rate=30 -c:v h263 sample_1920x1080.3gp

# 2560x1440 WMV
ffmpeg -f lavfi -i testsrc=duration=10:size=2560x1440:rate=30 -c:v wmv2 sample_2560x1440.wmv

# MOV QuickTime
ffmpeg -f lavfi -i testsrc=duration=10:size=1920x1080:rate=30 -c:v libx264 sample_1920x1080.mov

# HEVC/H.265 4K
ffmpeg -f lavfi -i testsrc=duration=10:size=3840x2160:rate=30 -c:v libx265 sample_3840x2160_hevc.mp4

# Portrait/Vertical video
ffmpeg -f lavfi -i testsrc=duration=10:size=1080x1920:rate=30 -c:v libx264 sample_1080x1920.mp4

# Video with rotation metadata (90 degrees)
ffmpeg -f lavfi -i testsrc=duration=10:size=1280x720:rate=30 -c:v libx264 -metadata:s:v:0 rotate=90 sample_1280x720_rotated.mp4

# FLV Flash Video
ffmpeg -f lavfi -i testsrc=duration=10:size=1920x1080:rate=30 -c:v flv sample_1920x1080.flv

# Ultrawide 21:9
ffmpeg -f lavfi -i testsrc=duration=10:size=2560x1080:rate=30 -c:v libx264 sample_ultrawide_21_9.mp4

# Video with embedded subtitles
ffmpeg -f lavfi -i testsrc=duration=10:size=1920x1080:rate=30 -f lavfi -i "nullsrc=s=1920x1080" -filter_complex "[1:v]subtitles=sample.srt[v]" -map "[v]" -c:v libx264 sample_with_subtitles.mkv

# Video with multiple audio tracks
ffmpeg -f lavfi -i testsrc=duration=10:size=1920x1080:rate=30 -f lavfi -i sine=frequency=1000:duration=10 -f lavfi -i sine=frequency=500:duration=10 -map 0:v -map 1:a -map 2:a -c:v libx264 -c:a aac sample_multi_audio.mkv
```

## File Structure

```
test/assets/
├── README.md (this file)
├── sample_640x360.mkv
├── sample_1280x720.avi
├── sample_1280x720.webm
├── sample_1920x1080.3gp
├── sample_2560x1440.wmv
└── Подводный_мир_Красное_море_4K.mp4
```

## Running Tests Without Video Files

If you don't have the video files, the integration tests will be skipped automatically. Unit tests will still run normally.

```powershell
# This will work without video files
flutter test test/smart_video_info_test.dart
```

## Adding Your Own Test Videos

You can add additional test videos and create corresponding tests in `test/integration_test.dart`. Just follow the existing test patterns.
