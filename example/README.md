# smart_video_info_example

Example app demonstrating the smart_video_info plugin.

## Features

- Select video from device storage
- Display video metadata with extraction time benchmark
- Shows all available properties (resolution, duration, codec, fps, audio info, etc.)

## Running

```bash
cd example
flutter pub get
flutter run
```

## Screenshot

The app displays:
- **Extraction time** — How long it took to extract metadata (typically <20ms)
- **Video info** — Resolution, duration, codec, FPS, bitrate, rotation, container
- **Audio info** — Audio codec, sample rate, channels
- **Other** — Subtitles, stream count
