import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'edit_teacher_profile_screen.dart';

class TeacherProfileScreen extends StatefulWidget {
  final bool embedded;
  const TeacherProfileScreen({super.key, this.embedded = false});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  bool _notificationsOn = true;
  bool _loggingOut = false;
  late Future<RepoResult<Teacher>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchTeacherProfile();
  }

  Future<void> _savePreferences() async {
    try {
      await AppRepository.instance.updatePreferences(notifications: _notificationsOn, darkMode: ThemeController.isDark.value);
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

  Future<void> _editProfile(Teacher teacher) async {
    final updated = await Navigator.of(context).push<bool>(fadeRoute(EditTeacherProfileScreen(teacher: teacher)));
    if (updated == true) {
      setState(() {
        _future = AppRepository.instance.fetchTeacherProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RepoResult<Teacher>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          final loading = Column(
            children: [
              const SkeletonBox(height: 240, radius: 0),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: const [SkeletonBox(height: 190, radius: 20)],
                ),
              ),
            ],
          );
          return widget.embedded ? loading : Scaffold(body: SafeArea(child: loading));
        }
        return _buildBody(context, snapshot.data!);
      },
    );
  }

  Widget _buildBody(BuildContext context, RepoResult<Teacher> result) {
    final teacher = result.data;

    final body = Column(
      children: [
        ProfileHeroHeader(name: teacher.name, subtitle: teacher.username, onEdit: () => _editProfile(teacher)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              if (result.isDemo) const DemoModeBanner(),

              ProfileDetailsCard(rows: [
                (icon: Icons.badge_outlined, label: 'Username', value: teacher.username),
                (icon: Icons.email_outlined, label: 'Email', value: teacher.email),
                (icon: Icons.verified_outlined, label: 'Status', value: teacher.status.isEmpty ? '—' : teacher.status),
              ]),
              const SizedBox(height: 22),

              Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Container(
                decoration: softCardDecoration(),
                child: Column(
                  children: [
                    SettingsSwitchTile(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      value: _notificationsOn,
                      onChanged: (v) {
                        setState(() => _notificationsOn = v);
                        _savePreferences();
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    ValueListenableBuilder<bool>(
                      valueListenable: ThemeController.isDark,
                      builder: (context, isDark, _) => SettingsSwitchTile(
                        icon: Icons.dark_mode_outlined,
                        label: 'Dark Mode',
                        value: isDark,
                        onChanged: (v) {
                          ThemeController.setDark(v);
                          _savePreferences();
                        },
                      ),
                    ),
                    const Divider(height: 1, indent: 60),
                    const SettingsNavTile(icon: Icons.settings_outlined, label: 'Settings'),
                    const Divider(height: 1, indent: 60),
                    const SettingsNavTile(icon: Icons.help_outline_rounded, label: 'Help & Support'),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              LogoutButton(loading: _loggingOut, onPressed: _logout),
            ],
          ),
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(body: SafeArea(child: body));
  }
}
