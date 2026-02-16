export 'src/smart_video_info_model.dart';
export 'src/smart_video_info_plugin.dart';

// Conditional export for web
export 'src/smart_video_info_web.dart'
    if (dart.library.io) 'src/smart_video_info_plugin.dart';
