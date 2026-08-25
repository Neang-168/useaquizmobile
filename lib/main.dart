import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  ThemeController.load();
  runApp(const PreStudyAssessmentApp());
}

class PreStudyAssessmentApp extends StatelessWidget {
  const PreStudyAssessmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDark,
      builder: (context, isDark, _) => MaterialApp(
        title: 'Pre-Study IT Knowledge Assessment',
        debugShowCheckedModeBanner: false,
        theme: isDark ? AppTheme.dark : AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
