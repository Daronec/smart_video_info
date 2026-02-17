/// Константы приложения.
class AppConstants {
  // Приватный конструктор для предотвращения создания экземпляров
  AppConstants._();

  // === Строковые константы ===
  
  /// Название приложения
  static const String appTitle = 'Smart Video Info Demo';
  
  /// Заголовок страницы
  static const String pageTitle = 'Smart Video Info';
  
  /// Текст кнопки выбора видео
  static const String selectVideoButton = 'Select Video';
  
  /// Текст индикатора загрузки
  static const String extractingMetadata = 'Extracting metadata...';
  
  /// Префикс времени извлечения
  static const String extractionTimePrefix = 'Extraction time: ';
  
  /// Суффикс миллисекунд
  static const String millisecondsSuffix = 'ms';
  
  // === Метки полей ===
  
  static const String labelFile = 'File';
  static const String labelVideo = 'Video';
  static const String labelAudio = 'Audio';
  static const String labelOther = 'Other';
  static const String labelResolution = 'Resolution';
  static const String labelDuration = 'Duration';
  static const String labelCodec = 'Codec';
  static const String labelFps = 'FPS';
  static const String labelBitrate = 'Bitrate';
  static const String labelRotation = 'Rotation';
  static const String labelContainer = 'Container';
  static const String labelOrientation = 'Orientation';
  static const String labelHasAudio = 'Has Audio';
  static const String labelAudioCodec = 'Audio Codec';
  static const String labelSampleRate = 'Sample Rate';
  static const String labelChannels = 'Channels';
  static const String labelSubtitles = 'Subtitles';
  static const String labelStreamCount = 'Stream Count';
  
  // === Значения ===
  
  static const String valueYes = 'Yes';
  static const String valueNo = 'No';
  static const String valuePortrait = 'Portrait';
  static const String valueLandscape = 'Landscape';
  static const String valueStereo = 'Stereo (2)';
  
  // === Единицы измерения ===
  
  static const String unitDegrees = '°';
  static const String unitHz = ' Hz';
  static const String unitMbps = ' Mbps';
  static const String unitKbps = ' Kbps';
  static const String unitBps = ' bps';
  
  // === Отступы и размеры ===
  
  /// Основной отступ страницы
  static const double paddingPage = 16.0;
  
  /// Отступ внутри карточки
  static const double paddingCard = 16.0;
  
  /// Малый отступ внутри карточки
  static const double paddingCardSmall = 12.0;
  
  /// Вертикальный отступ строки информации
  static const double paddingInfoRowVertical = 6.0;
  
  /// Горизонтальный отступ между элементами
  static const double spacingSmall = 4.0;
  
  /// Средний отступ между элементами
  static const double spacingMedium = 8.0;
  
  /// Большой отступ между элементами
  static const double spacingLarge = 12.0;
  
  /// Отступ между секциями
  static const double spacingSection = 16.0;
  
  /// Размер иконки в строке информации
  static const double iconSizeInfoRow = 20.0;
  
  // === MIME типы видео ===
  
  /// Карта расширений файлов и соответствующих MIME типов
  static const Map<String, String> videoMimeTypes = {
    'mp4': 'video/mp4',
    'm4v': 'video/mp4',
    'webm': 'video/webm',
    'ogv': 'video/ogg',
    'ogg': 'video/ogg',
    'mov': 'video/quicktime',
    'avi': 'video/x-msvideo',
    'mkv': 'video/x-matroska',
    'flv': 'video/x-flv',
    '3gp': 'video/3gpp',
    'wmv': 'video/x-ms-wmv',
  };
  
  /// MIME тип по умолчанию для видео
  static const String defaultVideoMimeType = 'video/mp4';
  
  // === Форматирование ===
  
  /// Количество знаков после запятой для FPS
  static const int fpsFractionDigits = 2;
  
  /// Количество знаков после запятой для Mbps
  static const int mbpsFractionDigits = 2;
  
  /// Количество знаков после запятой для Kbps
  static const int kbpsFractionDigits = 0;
  
  /// Порог для отображения в Mbps (1 000 000 bps)
  static const int bitrateThresholdMbps = 1000000;
  
  /// Порог для отображения в Kbps (1 000 bps)
  static const int bitrateThresholdKbps = 1000;
  
  /// Количество каналов для стерео
  static const int stereoChannels = 2;
}
