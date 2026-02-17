import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'pages/video_info_page.dart';

/// Точка входа в приложение.
void main() {
  runApp(const MyApp());
}

/// Корневой виджет приложения.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VideoInfoPage(),
    );
  }
}
