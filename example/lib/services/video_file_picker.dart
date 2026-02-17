import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants/app_constants.dart';
import 'video_file_picker_web.dart' if (dart.library.io) 'video_file_picker_io.dart';

/// Сервис для выбора видео файлов.
class VideoFilePicker {
  /// Открывает диалог выбора видео файла.
  /// 
  /// Возвращает путь к файлу или null если файл не выбран.
  /// На веб-платформе создает blob URL.
  Future<String?> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    
    if (kIsWeb) {
      return createBlobUrl(file);
    }
    
    return file.path;
  }
}
