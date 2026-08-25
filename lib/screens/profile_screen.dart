import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn = true;
  bool _loggingOut = false;
  late Future<RepoResult<Student>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchProfile();
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

  Future<void> _editProfile(Student student) async {
    final updated = await Navigator.of(context).push<bool>(fadeRoute(EditProfileScreen(student: student)));
    if (updated == true) {
      setState(() {
        _future = AppRepository.instance.fetchProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RepoResult<Student>>(
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

  Widget _buildBody(BuildContext context, RepoResult<Student> result) {
    final student = result.data;

    final body = Column(
      children: [
        ProfileHeroHeader(name: student.name, subtitle: student.id, onEdit: () => _editProfile(student)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              if (result.isDemo) const DemoModeBanner(),

              ProfileDetailsCard(rows: [
                (icon: Icons.email_outlined, label: 'Email', value: student.email),
                (icon: Icons.school_outlined, label: 'Faculty', value: student.faculty),
                (icon: Icons.book_outlined, label: 'Major', value: student.major),
                (icon: Icons.calendar_month_outlined, label: 'Academic Year', value: student.academicYear),
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
