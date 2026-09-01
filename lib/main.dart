import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_client.dart';
import 'widgets/common_widgets.dart';
import 'l10n/generated/app_localizations.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([ThemeController.load(), LocaleController.load()]);
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
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDark,
      builder: (context, isDark, _) => ValueListenableBuilder<Locale>(
        valueListenable: LocaleController.locale,
        builder: (context, locale, _) => MaterialApp(
          navigatorKey: navigatorKey,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: isDark ? AppTheme.dark : AppTheme.light,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
