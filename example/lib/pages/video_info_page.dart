import 'package:flutter/material.dart';
import 'package:smart_video_info/smart_video_info.dart';
import '../constants/app_constants.dart';
import '../services/video_file_picker.dart';
import '../services/video_info_service.dart';
import '../widgets/video_info_cards.dart';

/// Страница отображения информации о видео.
class VideoInfoPage extends StatefulWidget {
  const VideoInfoPage({super.key});

  @override
  State<VideoInfoPage> createState() => _VideoInfoPageState();
}

class _VideoInfoPageState extends State<VideoInfoPage> {
  final _filePicker = VideoFilePicker();
  final _infoService = VideoInfoService();

  SmartVideoInfo? _videoInfo;
  String? _selectedPath;
  bool _isLoading = false;
  String? _error;
  int? _extractionTimeMs;

  /// Обрабатывает выбор видео файла.
  Future<void> _handlePickVideo() async {
    try {
      final path = await _filePicker.pickVideo();

      if (path != null) {
        await _loadVideoInfo(path);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      _setError('Error picking file: $e');
    }
  }

  /// Загружает информацию о видео.
  Future<void> _loadVideoInfo(String path) async {
    _setLoadingState(path);

    try {
      final result = await _infoService.getVideoInfo(path);
      _setSuccessState(result);
    } on SmartVideoInfoException catch (e) {
      debugPrint('SmartVideoInfoException: ${e.message}');
      _setError(e.message);
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      _setError('Unexpected error: $e');
    }
  }

  /// Устанавливает состояние загрузки.
  void _setLoadingState(String path) {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedPath = path;
      _videoInfo = null;
      _extractionTimeMs = null;
    });
  }

  /// Устанавливает состояние успешной загрузки.
  void _setSuccessState(VideoInfoResult result) {
    setState(() {
      _videoInfo = result.info;
      _extractionTimeMs = result.extractionTimeMs;
      _isLoading = false;
    });
  }

  /// Устанавливает состояние ошибки.
  void _setError(String error) {
    setState(() {
      _error = error;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(AppConstants.pageTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPickButton(),
            const SizedBox(height: AppConstants.spacingSection),
            if (_isLoading) _buildLoadingIndicator(),
            if (_error != null) _buildErrorCard(),
            if (_videoInfo != null) _buildVideoInfoCards(),
          ],
        ),
      ),
    );
  }

  /// Строит кнопку выбора видео.
  Widget _buildPickButton() {
    return FilledButton.icon(
      onPressed: _isLoading ? null : _handlePickVideo,
      icon: const Icon(Icons.video_library),
      label: const Text(AppConstants.selectVideoButton),
    );
  }

  /// Строит индикатор загрузки.
  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppConstants.spacingMedium),
          Text(AppConstants.extractingMetadata),
        ],
      ),
    );
  }

  /// Строит карточку с ошибкой.
  Widget _buildErrorCard() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingCard),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Строит карточки с информацией о видео.
  Widget _buildVideoInfoCards() {
    return Column(
      children: [
        if (_extractionTimeMs != null)
          PerformanceCard(extractionTimeMs: _extractionTimeMs!),
        const SizedBox(height: AppConstants.spacingMedium),
        if (_selectedPath != null) FilePathCard(path: _selectedPath!),
        const SizedBox(height: AppConstants.spacingMedium),
        VideoPropertiesCard(videoInfo: _videoInfo!),
        const SizedBox(height: AppConstants.spacingMedium),
        AudioPropertiesCard(videoInfo: _videoInfo!),
        const SizedBox(height: AppConstants.spacingMedium),
        OtherPropertiesCard(videoInfo: _videoInfo!),
      ],
    );
  }
}
