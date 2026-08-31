import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'edit_teacher_profile_screen.dart';
import 'schedule_screen.dart';
import 'teacher_results_screen.dart';
import 'classrooms_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import '../l10n/generated/app_localizations.dart';

class TeacherProfileScreen extends StatefulWidget {
  final bool embedded;
  const TeacherProfileScreen({super.key, this.embedded = false});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileData {
  final Teacher teacher;
  final TeacherDashboardStats stats;
  const _TeacherProfileData({required this.teacher, required this.stats});
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  bool _notificationsOn = true;
  bool _loggingOut = false;
  late Future<_TeacherProfileData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _loadPreferences();
  }

  Future<_TeacherProfileData> _load() async {
    final repo = AppRepository.instance;
    final results = await Future.wait([repo.fetchTeacherProfile(), repo.fetchTeacherDashboard()]);
    return _TeacherProfileData(teacher: results[0] as Teacher, stats: results[1] as TeacherDashboardStats);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _notificationsOn = prefs.getBool('pref_notifications') ?? true);
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
        _future = _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TeacherProfileData>(
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

  Widget _buildBody(BuildContext context, _TeacherProfileData data) {
    final l = AppLocalizations.of(context);
    final teacher = data.teacher;
    final score = data.stats.averageScore.clamp(0, 100).toDouble();

    final body = Column(
      children: [
        BrandHeaderBar(
          initials: _initials(teacher.name),
          onAvatarTap: () => _editProfile(teacher),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              GaugeStatCard(
                title: l.classPerformance,
                percent: score / 100,
                centerLabel: '${score.toStringAsFixed(1)}%',
                doneLabel: l.averageScoreLabel,
                remainingLabel: l.remainingTo100,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  children: [
                    ShortcutGrid(tiles: [
                      ShortcutTile(icon: Icons.edit_outlined, label: l.editProfileLabel, onTap: () => _editProfile(teacher)),
                      ShortcutTile(
                        icon: Icons.calendar_month_outlined,
                        label: l.scheduleLabel,
                        onTap: () => Navigator.of(context).push(fadeRoute(const ScheduleScreen())),
                      ),
                      ShortcutTile(
                        icon: Icons.fact_check_outlined,
                        label: l.resultsLabel,
                        onTap: () => Navigator.of(context).push(fadeRoute(const TeacherResultsScreen())),
                      ),
                      ShortcutTile(
                        icon: Icons.meeting_room_outlined,
                        label: l.classesLabel,
                        onTap: () => Navigator.of(context).push(fadeRoute(const ClassRoomsScreen())),
                      ),
                    ]),
                    const SizedBox(height: 22),

                    ProfileDetailsCard(rows: [
                      (icon: Icons.badge_outlined, label: l.usernameLabel, value: teacher.username),
                      (icon: Icons.email_outlined, label: l.emailLabel, value: teacher.email),
                      (icon: Icons.verified_outlined, label: l.statusLabel, value: teacher.status.isEmpty ? '—' : teacher.status),
                    ]),
                    const SizedBox(height: 22),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(l.preferencesTitle, style: Theme.of(context).textTheme.titleLarge),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: softCardDecoration(),
                      child: Column(
                        children: [
                          SettingsSwitchTile(
                            icon: Icons.notifications_outlined,
                            label: l.notificationsLabel,
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
                              label: l.darkModeLabel,
                              value: isDark,
                              onChanged: (v) {
                                ThemeController.setDark(v);
                                _savePreferences();
                              },
                            ),
                          ),
                          const Divider(height: 1, indent: 60),
                          SettingsNavTile(
                            icon: Icons.settings_outlined,
                            label: l.settingsNav,
                            onTap: () => Navigator.of(context).push(fadeRoute(const SettingsScreen())),
                          ),
                          const Divider(height: 1, indent: 60),
                          SettingsNavTile(
                            icon: Icons.help_outline_rounded,
                            label: l.helpSupportNav,
                            onTap: () => Navigator.of(context).push(fadeRoute(const HelpSupportScreen())),
                          ),
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
