import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_client.dart';
import 'widgets/common_widgets.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Whenever a request comes back 401 (expired/invalid token), bounce back
  // to the login screen from wherever the user currently is.
  ApiClient.onUnauthorized = () {
    navigatorKey.currentState?.pushAndRemoveUntil(fadeRoute(const LoginScreen()), (r) => false);
  };
  runApp(const PreStudyAssessmentApp());
}

class PreStudyAssessmentApp extends StatelessWidget {
  const PreStudyAssessmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Pre-Study IT Knowledge Assessment',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
