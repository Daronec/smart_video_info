import 'package:file_picker/file_picker.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html show Url, Blob;
import '../constants/app_constants.dart';

/// Создает blob URL для веб-платформы.
/// 
/// Принимает [file] и создает blob URL из его байтов.
/// Возвращает URL или null если байты отсутствуют.
String? createBlobUrl(PlatformFile file) {
  final bytes = file.bytes;
  if (bytes == null) return null;
  
  final mimeType = _getMimeType(file.name);
  final blob = html.Blob([bytes], mimeType);
  return html.Url.createObjectUrlFromBlob(blob);
}

/// Определяет MIME-тип видео по расширению файла.
/// 
/// Извлекает расширение из [fileName] и возвращает соответствующий MIME-тип.
/// Если расширение не найдено, возвращает MIME-тип по умолчанию.
String _getMimeType(String fileName) {
  final extension = fileName.toLowerCase().split('.').last;
  return AppConstants.videoMimeTypes[extension] ?? 
         AppConstants.defaultVideoMimeType;
}
