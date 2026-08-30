import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'schedule_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileData {
  final Student student;
  final StudentDashboardStats stats;
  const _ProfileData({required this.student, required this.stats});
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn = true;
  bool _loggingOut = false;
  late Future<_ProfileData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProfileData> _load() async {
    final repo = AppRepository.instance;
    final results = await Future.wait([repo.fetchProfile(), repo.fetchStudentDashboard()]);
    return _ProfileData(student: results[0] as Student, stats: results[1] as StudentDashboardStats);
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
        _future = _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProfileData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          final loading = Column(
            children: [
              const SkeletonBox(height: 170, radius: 0),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: const [
                    SkeletonBox(height: 100, radius: 20),
                    SizedBox(height: 12),
                    SkeletonBox(height: 100, radius: 20),
                    SizedBox(height: 22),
                    SkeletonBox(height: 150, radius: 20),
                  ],
                ),
              ),
            ],
          );
          return widget.embedded ? loading : Scaffold(body: SafeArea(child: loading));
        }
        if (snapshot.hasError) {
          final error = ErrorStateView(
            message: describeApiError(snapshot.error!),
            onRetry: () => setState(() => _future = _load()),
          );
          return widget.embedded ? error : Scaffold(body: SafeArea(child: error));
        }
        return _buildBody(context, snapshot.data!);
      },
    );
  }

  Widget _buildBody(BuildContext context, _ProfileData data) {
    final student = data.student;
    final completed = data.stats.completedCount;
    final total = completed + data.stats.todoCount;
    final percent = total == 0 ? 0.0 : completed / total;

    final body = Column(
      children: [
        BrandHeaderBar(
          initials: _initials(student.name),
          onAvatarTap: () => _editProfile(student),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              GaugeStatCard(
                title: 'Your Learning Progress',
                percent: percent,
                centerLabel: '$completed/$total',
                doneLabel: 'Completed',
                remainingLabel: 'To do',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  children: [
                    ShortcutGrid(tiles: [
                      ShortcutTile(icon: Icons.edit_outlined, label: 'Edit Profile', onTap: () => _editProfile(student)),
                      ShortcutTile(
                        icon: Icons.calendar_month_outlined,
                        label: 'Schedule',
                        onTap: () => Navigator.of(context).push(fadeRoute(const ScheduleScreen())),
                      ),
                      ShortcutTile(
                        icon: Icons.history_rounded,
                        label: 'History',
                        onTap: () => Navigator.of(context).push(fadeRoute(const HistoryScreen())),
                      ),
                      ShortcutTile(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () => Navigator.of(context).push(fadeRoute(const NotificationsScreen())),
                      ),
                    ]),
                    const SizedBox(height: 22),

                    ProfileDetailsCard(rows: [
                      (icon: Icons.email_outlined, label: 'Email', value: student.email),
                      (icon: Icons.book_outlined, label: 'Major', value: student.major ?? '—'),
                      (icon: Icons.meeting_room_outlined, label: 'Class', value: student.className ?? '—'),
                      (icon: Icons.calendar_month_outlined, label: 'Academic Year', value: student.academicYear ?? '—'),
                    ]),
                    const SizedBox(height: 22),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
                    ),
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
          ),
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(body: SafeArea(child: body));
  }
}

String _initials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.split(RegExp(r'\s+')).map((w) => w[0]).take(2).join().toUpperCase();
}
