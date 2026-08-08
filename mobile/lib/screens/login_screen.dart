import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/app_repository.dart';
import '../services/api_client.dart';
import 'home_screen.dart';

// Brand palette for this screen, matched to the university's web login page
// (indigo/violet accent, soft lavender surfaces). Scoped locally rather than
// added to AppColors since only this screen has been rebranded so far —
// promote these into app_theme.dart if the rest of the app follows suit.
class _Brand {
  _Brand._();
  static const indigo = Color(0xFF6366F1);
  static const pageBg = Color(0xFFEEF1FB);
  static const fieldFill = Color(0xFFF1F2FB);
  static const textDark = Color(0xFF1E1B3A);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
  bool _rememberMe = true;
  bool _loading = false;
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  late final TapGestureRecognizer _signUpRecognizer = TapGestureRecognizer()
    ..onTap = () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact your faculty office to create an account.')),
      );
    };

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _signUpRecognizer.dispose();
    super.dispose();
  }

  Future<void> _login({bool google = false}) async {
    setState(() => _loading = true);
    try {
      if (google) {
        await AppRepository.instance.loginWithGoogle(remember: _rememberMe);
      } else {
        await AppRepository.instance.login(
          identifier: _idController.text.trim(),
          password: _passwordController.text,
          remember: _rememberMe,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(fadeRoute(const HomeScreen()));
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isConnectivity) {
        // No backend reachable — proceed straight into the demo experience
        // rather than blocking the user, since the rest of the app already
        // falls back to mock data screen by screen.
        Navigator.of(context).pushReplacement(fadeRoute(const HomeScreen()));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _fieldDecoration({required String hint, required Widget prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _Brand.fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: _Brand.indigo, width: 1.6),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Brand.pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            children: [
              // ---- Branding header (crest, name, dot indicators) ----
              Container(
                width: 84,
                height: 84,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: _Brand.indigo.withOpacity(0.18), blurRadius: 24, offset: const Offset(0, 12)),
                  ],
                ),
                child: Image.asset('assets/usealogo.jpg', fit: BoxFit.contain),
              ),
              const SizedBox(height: 18),
              const Text(
                'University Quiz Management System',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _Brand.textDark, height: 1.3),
              ),
              const SizedBox(height: 8),
              const Text(
                "Welcome back! Sign in to continue your pre-study assessments.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 6, width: 22, decoration: BoxDecoration(color: _Brand.indigo, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  Container(height: 6, width: 6, decoration: BoxDecoration(color: _Brand.indigo.withOpacity(0.25), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Container(height: 6, width: 6, decoration: BoxDecoration(color: _Brand.indigo.withOpacity(0.25), shape: BoxShape.circle)),
                ],
              ),
              const SizedBox(height: 28),

              // ---- Login card ----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _Brand.textDark)),
                    const SizedBox(height: 22),

                    _fieldLabel('Username or Email'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _idController,
                      decoration: _fieldDecoration(
                        hint: 'ITU2023-0142 or name@usea.edu.kh',
                        prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textMuted, size: 20),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _fieldLabel('Password'),
                        GestureDetector(
                          onTap: () {},
                          child: const Text('Forgot password?',
                              style: TextStyle(color: _Brand.indigo, fontWeight: FontWeight.w600, fontSize: 12.5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: _fieldDecoration(
                        hint: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textMuted, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: _Brand.indigo,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            onChanged: (v) => setState(() => _rememberMe = v ?? true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Remember me', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _Brand.indigo,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                        ),
                        onPressed: _loading ? null : () => _login(),
                        child: _loading
                            ? const SizedBox(
                                width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or continue with', style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        const Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border, width: 1.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        ),
                        onPressed: _loading ? null : () => _login(google: true),
                        icon: const Icon(Icons.g_mobiledata_rounded, color: AppColors.danger, size: 26),
                        label: const Text('Sign in with Google'),
                      ),
                    ),
                    const SizedBox(height: 22),

                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Sign up',
                              style: const TextStyle(color: _Brand.indigo, fontWeight: FontWeight.w700),
                              recognizer: _signUpRecognizer,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}