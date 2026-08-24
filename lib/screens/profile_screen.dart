import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn = true;
  bool _darkMode = false;
  bool _loggingOut = false;
  late Future<RepoResult<Student>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchProfile();
  }

  Future<void> _savePreferences() async {
    try {
      await AppRepository.instance.updatePreferences(notifications: _notificationsOn, darkMode: _darkMode);
    } catch (_) {
      // best-effort; preferences already reflected in local UI state
    }
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    await AppRepository.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(fadeRoute(const LoginScreen()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RepoResult<Student>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          final loading = ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: const [
              SkeletonBox(height: 40, radius: 12),
              SizedBox(height: 20),
              SkeletonBox(height: 190, radius: 20),
            ],
          );
          return widget.embedded ? loading : Scaffold(body: SafeArea(child: loading));
        }
        return _buildBody(context, snapshot.data!);
      },
    );
  }

  Widget _buildBody(BuildContext context, RepoResult<Student> result) {
    final student = result.data;
    final initials = student.name.trim().isEmpty
        ? '?'
        : student.name.trim().split(RegExp(r'\s+')).map((w) => w[0]).take(2).join().toUpperCase();

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 14),
        if (result.isDemo) const DemoModeBanner(),
        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(AppRadius.lg)),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 3),
                ),
                child: Center(
                  child: Text(initials, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 12),
              Text(student.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(student.username, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: softCardDecoration(),
          child: Column(
            children: [
              _detailRow(context, Icons.book_outlined, 'Major', student.major ?? '—'),
              const Divider(height: 24),
              _detailRow(context, Icons.meeting_room_outlined, 'Class', student.className ?? '—'),
              const Divider(height: 24),
              _detailRow(context, Icons.calendar_month_outlined, 'Academic Year', student.academicYear ?? '—'),
            ],
          ),
        ),
        const SizedBox(height: 22),

        Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Container(
          decoration: softCardDecoration(),
          child: Column(
            children: [
              _switchTile(context, Icons.notifications_outlined, 'Notifications', _notificationsOn, (v) {
                setState(() => _notificationsOn = v);
                _savePreferences();
              }),
              const Divider(height: 1, indent: 60),
              _switchTile(context, Icons.dark_mode_outlined, 'Dark Mode', _darkMode, (v) {
                setState(() => _darkMode = v);
                _savePreferences();
              }),
              const Divider(height: 1, indent: 60),
              _navTile(context, Icons.settings_outlined, 'Settings'),
              const Divider(height: 1, indent: 60),
              _navTile(context, Icons.help_outline_rounded, 'Help & Support'),
            ],
          ),
        ),
        const SizedBox(height: 22),

        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
          onPressed: _loggingOut ? null : _logout,
          icon: _loggingOut
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger))
              : const Icon(Icons.logout_rounded, size: 18),
          label: Text(_loggingOut ? 'Logging out...' : 'Log Out'),
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(body: SafeArea(child: body));
  }

  Widget _detailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Flexible(child: Text(value, textAlign: TextAlign.end, style: Theme.of(context).textTheme.titleMedium)),
      ],
    );
  }

  Widget _switchTile(BuildContext context, IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          IconBadge(icon: icon, color: AppColors.primary, size: 38),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
          Switch(value: value, activeColor: AppColors.primary, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _navTile(BuildContext context, IconData icon, String label) {
    return ListTile(
      leading: IconBadge(icon: icon, color: AppColors.primary, size: 38),
      title: Text(label, style: Theme.of(context).textTheme.titleMedium),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: () {},
    );
  }
}
