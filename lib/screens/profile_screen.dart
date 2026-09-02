import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'schedule_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import '../l10n/generated/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileData {
  final Student student;
  final StudentDashboardStats stats;
  final AssessmentProgress progress;
  const _ProfileData({
    required this.student,
    required this.stats,
    required this.progress,
  });
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn = true;
  bool _loggingOut = false;
  late Future<_ProfileData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _loadPreferences();
  }

  Future<_ProfileData> _load() async {
    final repo = AppRepository.instance;
    final results = await Future.wait([
      repo.fetchProfile(),
      repo.fetchStudentDashboard(),
      repo.fetchAllAssessments(),
    ]);
    return _ProfileData(
      student: results[0] as Student,
      stats: results[1] as StudentDashboardStats,
      progress: AssessmentProgress.fromAssessments(
        results[2] as List<Assessment>,
      ),
    );
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(
      () => _notificationsOn = prefs.getBool('pref_notifications') ?? true,
    );
  }

  Future<void> _savePreferences() async {
    try {
      await AppRepository.instance.updatePreferences(
        notifications: _notificationsOn,
        darkMode: ThemeController.isDark.value,
      );
    } catch (_) {
      // best-effort; preferences already reflected in local UI state
    }
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    await AppRepository.instance.logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushAndRemoveUntil(fadeRoute(const LoginScreen()), (r) => false);
  }

  Future<void> _editProfile(Student student) async {
    final updated = await Navigator.of(
      context,
    ).push<bool>(fadeRoute(EditProfileScreen(student: student)));
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
          return widget.embedded
              ? loading
              : Scaffold(body: SafeArea(child: loading));
        }
        if (snapshot.hasError) {
          final error = ErrorStateView(
            message: describeApiError(snapshot.error!),
            onRetry: () => setState(() => _future = _load()),
          );
          return widget.embedded
              ? error
              : Scaffold(body: SafeArea(child: error));
        }
        return _buildBody(context, snapshot.data!);
      },
    );
  }

  Widget _buildBody(BuildContext context, _ProfileData data) {
    final l = AppLocalizations.of(context);
    final student = data.student;
    final completed = data.progress.completed;
    final total = data.progress.total;
    final percent = data.progress.percent;

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
                title: l.yourLearningProgress,
                percent: percent,
                centerLabel: '$completed/$total',
                doneLabel: l.completedChartLabel,
                remainingLabel: l.todoChartLabel,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  children: [
                    ShortcutGrid(
                      tiles: [
                        ShortcutTile(
                          icon: Icons.edit_outlined,
                          label: l.editProfileLabel,
                          onTap: () => _editProfile(student),
                        ),
                        ShortcutTile(
                          icon: Icons.lock_outline_rounded,
                          label: l.changePasswordLabel,
                          onTap: () => Navigator.of(
                            context,
                          ).push(fadeRoute(const ChangePasswordScreen())),
                        ),
                        ShortcutTile(
                          icon: Icons.calendar_month_outlined,
                          label: l.scheduleLabel,
                          onTap: () => Navigator.of(
                            context,
                          ).push(fadeRoute(const ScheduleScreen())),
                        ),
                        ShortcutTile(
                          icon: Icons.history_rounded,
                          label: l.historyLabel,
                          onTap: () => Navigator.of(
                            context,
                          ).push(fadeRoute(const HistoryScreen())),
                        ),
                        ShortcutTile(
                          icon: Icons.notifications_outlined,
                          label: l.notificationsLabel,
                          onTap: () => Navigator.of(
                            context,
                          ).push(fadeRoute(const NotificationsScreen())),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l.personalInformationTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: softCardDecoration(),
                      child: _InfoTileGrid(
                        items: [
                          (l.usernameLabel, student.username),
                          (l.roleLabel, student.role),
                          (
                            l.statusLabel,
                            student.status ? l.activeLabel : l.inactiveLabel,
                          ),
                          (l.joinedLabel, formatDisplayDate(student.createdAt)),
                          (l.genderLabel, _genderLabel(student.gender, l)),
                          (l.dobLabel, formatDisplayDate(student.dob)),
                          (l.phoneLabel, student.phone),
                          (l.emailLabel, student.email),
                          if (student.nameKh.isNotEmpty)
                            (l.khmerNameLabel, student.nameKh),
                          if (student.address.isNotEmpty)
                            (l.addressLabel, student.address),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l.academicInformationTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: softCardDecoration(),
                      child: student.hasEnrollment
                          ? _InfoTileGrid(
                              items: [
                                (
                                  l.studentCodeLabel,
                                  student.studentCode ?? '—',
                                ),
                                (
                                  l.admissionDateLabel,
                                  formatDisplayDate(student.admissionDate),
                                ),
                                (l.classLabel, student.className ?? '—'),
                                (l.majorLabel, student.major ?? '—'),
                                (l.facultyLabel, student.faculty ?? '—'),
                                (l.degreeLabel, student.degree ?? '—'),
                                (
                                  l.academicYearLabel,
                                  student.academicYear ?? '—',
                                ),
                                (l.semesterLabel, student.semester ?? '—'),
                                (l.termLabel, student.term ?? '—'),
                                (l.shiftLabel, student.shift ?? '—'),
                                (l.stageLabel, student.stage ?? '—'),
                                (l.promotionLabel, student.promotion ?? '—'),
                                (
                                  l.enrollmentDateLabel,
                                  formatDisplayDate(student.enrollmentDate),
                                ),
                                (
                                  l.enrollmentStatusLabel,
                                  _genericStatusLabel(
                                    student.enrollmentStatus,
                                    l,
                                  ),
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                l.noEnrollmentRecordSubtitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                    ),
                    const SizedBox(height: 22),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l.preferencesTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
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
                            onTap: () => Navigator.of(
                              context,
                            ).push(fadeRoute(const SettingsScreen())),
                          ),
                          const Divider(height: 1, indent: 60),
                          SettingsNavTile(
                            icon: Icons.help_outline_rounded,
                            label: l.helpSupportNav,
                            onTap: () => Navigator.of(
                              context,
                            ).push(fadeRoute(const HelpSupportScreen())),
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
  return trimmed
      .split(RegExp(r'\s+'))
      .map((w) => w[0])
      .take(2)
      .join()
      .toUpperCase();
}

String _genderLabel(String raw, AppLocalizations l) => switch (raw) {
  'Male' => l.genderMale,
  'Female' => l.genderFemale,
  _ => '—',
};

String _genericStatusLabel(String? raw, AppLocalizations l) => switch (raw) {
  'Active' => l.activeLabel,
  'Inactive' => l.inactiveLabel,
  _ => raw?.isNotEmpty == true ? raw! : '—',
};

/// A 2-column grid of label/value tiles — used for the profile's read-only
/// Personal/Academic Information sections. An odd trailing item spans full
/// width instead of leaving an empty cell.
class _InfoTileGrid extends StatelessWidget {
  final List<(String, String)> items;
  const _InfoTileGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      final hasSecond = i + 1 < items.length;
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _InfoTile(label: items[i].$1, value: items[i].$2),
              ),
              if (hasSecond) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoTile(
                    label: items[i + 1].$1,
                    value: items[i + 1].$2,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? '—' : value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
