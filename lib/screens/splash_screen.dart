import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/session.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'teacher_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<Offset> _slide =
      Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () async {
      // A "Remember me" login persists the token/role to disk (see
      // Session.saveToken); if one is there, skip straight past Login into
      // the right role's home screen instead of forcing a re-login every
      // time the app is relaunched.
      final token = await Session.loadToken();
      final role = await Session.loadRole();
      if (!mounted) return;
      final destination = (token == null || token.isEmpty)
          ? const LoginScreen()
          : (role == UserRole.teacher.name
                ? const TeacherHomeScreen()
                : const HomeScreen());
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destination,
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // University badge
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 14),
                  const Text('University of Southeast Asia',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                  const Spacer(flex: 1),
                  // App logo
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 14))],
                    ),
                    child: const Icon(Icons.fact_check_rounded, color: AppColors.primary, size: 54),
                  ),
                  const SizedBox(height: 24),
                  const Text('Pre-Study IT\nKnowledge Assessment',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, height: 1.3)),
                  const SizedBox(height: 10),
                  const Text('Know where you stand before class begins',
                      style: TextStyle(color: Colors.white70, fontSize: 13.5)),
                  const Spacer(flex: 2),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
