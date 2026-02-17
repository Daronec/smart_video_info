import 'package:file_picker/file_picker.dart';

/// Заглушка для IO платформ (не используется).
/// На IO платформах используется file.path напрямую.
String? createBlobUrl(PlatformFile file) {
  // На IO платформах blob URL не нужен
  return null;
}
