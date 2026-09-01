import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import '../l10n/generated/app_localizations.dart';
import 'schedule_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  final bool embedded;
  const TeacherDashboardScreen({super.key, this.embedded = false});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _DashboardData {
  final String teacherName;
  final TeacherDashboardStats stats;
  const _DashboardData({required this.teacherName, required this.stats});
}

String _greeting(AppLocalizations l) {
  final h = DateTime.now().hour;
  if (h < 12) return l.goodMorning;
  if (h < 17) return l.goodAfternoon;
  return l.goodEvening;
}

String _initials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.split(RegExp(r'\s+')).map((w) => w[0]).take(2).join().toUpperCase();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DashboardData> _load() async {
    final repo = AppRepository.instance;
    final results = await Future.wait([
      repo.fetchTeacherProfile(),
      repo.fetchTeacherDashboard(),
    ]);
    final teacher = results[0] as Teacher;
    final stats = results[1] as TeacherDashboardStats;
    final name = '${teacher.firstName} ${teacher.lastName}'.trim();
    return _DashboardData(
      teacherName: name.isEmpty ? teacher.username : name,
      stats: stats,
    );
  }

  void _retry() => setState(() => _future = _load());

  Future<void> _refresh() async {
    final f = _load();
    setState(() => _future = f);
    try {
      await f;
    } catch (_) {
      // The FutureBuilder below already renders the error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DashboardData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          final loading = ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: const [
              SkeletonBox(height: 48, radius: 24),
              SizedBox(height: 22),
              SkeletonBox(height: 118, radius: 20),
              SizedBox(height: 16),
              SkeletonBox(height: 100, radius: 20),
              SizedBox(height: 16),
              SkeletonBox(height: 190, radius: 20),
              SizedBox(height: 16),
              SkeletonBox(height: 120, radius: 20),
            ],
          );
          return widget.embedded
              ? loading
              : Scaffold(body: SafeArea(child: loading));
        }
        if (snapshot.hasError) {
          final error = ErrorStateView(message: describeApiError(snapshot.error!), onRetry: _retry);
          return widget.embedded ? error : Scaffold(body: SafeArea(child: error));
        }
        final body = _buildBody(context, snapshot.data!);
        return widget.embedded ? body : Scaffold(body: SafeArea(child: body));
      },
    );
  }

  Widget _buildBody(BuildContext context, _DashboardData data) {
    final l = AppLocalizations.of(context);
    final stats = data.stats;
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          // Header: personalized greeting + avatar, matching the student
          // Home screen so both roles feel like the same app.
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials(data.teacherName),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting(l), style: Theme.of(context).textTheme.bodyMedium),
                    Text(data.teacherName, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(fadeRoute(const ScheduleScreen())),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Icon(Icons.calendar_month_rounded, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Headline KPIs in one gradient banner, matching the hero card
          // style already used on the student Home screen.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HeroStat(icon: Icons.meeting_room_rounded, value: '${stats.classesCount}', label: l.classesCountLabel),
                ),
                _heroDivider(),
                Expanded(
                  child: _HeroStat(icon: Icons.groups_rounded, value: '${stats.studentsCount}', label: l.studentsLabel),
                ),
                _heroDivider(),
                Expanded(
                  child: _HeroStat(
                    icon: Icons.fact_check_rounded,
                    value: '${stats.activeQuizzesCount}',
                    label: l.activeQuizzesLabel,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Secondary metrics as tinted cards, sized to their own content so
          // long labels/large text scale can't overflow.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.edit_note_rounded,
                    label: l.pendingEssaysLabel,
                    value: '${stats.pendingEssaysCount}',
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.emoji_events_rounded,
                    label: l.averageScoreLabel,
                    value: '${stats.averageScore.toStringAsFixed(1)}%',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          SectionHeader(title: l.submissionRatesTitle),
          const SizedBox(height: 12),
          if (stats.recentQuizzes.isEmpty)
            EmptyState(
              icon: Icons.bar_chart_rounded,
              title: l.noRecentQuizzes,
              subtitle: l.noRecentQuizzesSubmissionSubtitle,
            )
          else
            Container(
              height: 210,
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
              decoration: softCardDecoration(),
              child: _SubmissionRateChart(quizzes: stats.recentQuizzes),
            ),
          const SizedBox(height: 26),

          SectionHeader(title: l.recentQuizzesTitle),
          const SizedBox(height: 12),
          if (stats.recentQuizzes.isEmpty)
            EmptyState(
              icon: Icons.quiz_outlined,
              title: l.noRecentQuizzes,
              subtitle: l.noRecentQuizzesSubtitle,
            )
          else
            ...stats.recentQuizzes.map(
              (q) => _DashboardListTile(
                icon: Icons.quiz_rounded,
                iconColor: colorForSeed(q.id),
                title: q.title,
                subtitleLines: ['${q.subject} · ${q.className}', l.submittedCount(q.submittedCount, q.totalStudents)],
                trailing: StatusPill(
                  label: q.statusText,
                  color: q.statusText == 'Published' ? AppColors.success : AppColors.textMuted,
                ),
              ),
            ),
          const SizedBox(height: 26),

          SectionHeader(title: l.needsAttentionTitle),
          const SizedBox(height: 6),
          if (stats.needsAttention.isNotEmpty) ...[
            Text(l.rawPointTotalsNote, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
          ],
          if (stats.needsAttention.isEmpty)
            EmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: l.noStudentsFlagged,
              subtitle: l.noStudentsFlaggedSubtitle,
            )
          else
            ...stats.needsAttention.map(
              (e) => _DashboardListTile(
                icon: Icons.person_rounded,
                iconColor: AppColors.danger,
                title: e.name,
                subtitleLines: ['${e.subject} · ${e.className}'],
                trailing: StatusPill(label: l.ptsLabel(e.score), color: AppColors.danger),
                flagged: true,
              ),
            ),
          const SizedBox(height: 26),

          SectionHeader(title: l.upcomingQuizzesTitle),
          const SizedBox(height: 12),
          if (stats.upcomingQuizzes.isEmpty)
            EmptyState(
              icon: Icons.event_available_outlined,
              title: l.nothingScheduled,
              subtitle: l.nothingScheduledSubtitle,
            )
          else
            ...stats.upcomingQuizzes.map(
              (u) => _DashboardListTile(
                icon: Icons.event_rounded,
                iconColor: colorForSeed(u.id),
                title: u.title,
                subtitleLines: [
                  '${u.subject} · ${u.className}',
                  u.endAt == null ? l.noScheduleSet : l.dueDatePrefix(formatDisplayDate(u.endAt, withTime: true)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One KPI within the gradient hero banner atop the teacher dashboard.
class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _HeroStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

Widget _heroDivider() => Container(width: 1, height: 52, color: Colors.white.withValues(alpha: 0.18));

/// Shared row card for the three list sections (Recent Quizzes, Needs
/// Attention, Upcoming Quizzes) so they render with identical spacing and
/// typography. [flagged] swaps the plain white card for a soft danger tint —
/// the same "needs your attention" treatment used for unread notifications.
class _DashboardListTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> subtitleLines;
  final Widget? trailing;
  final bool flagged;
  const _DashboardListTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitleLines,
    this.trailing,
    this.flagged = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: flagged
            ? BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.18)),
              )
            : softCardDecoration(),
        child: Row(
          children: [
            IconBadge(icon: icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  for (final line in subtitleLines) ...[
                    const SizedBox(height: 2),
                    Text(line, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

class _SubmissionRateChart extends StatelessWidget {
  final List<TeacherQuizSummary> quizzes;
  const _SubmissionRateChart({required this.quizzes});

  @override
  Widget build(BuildContext context) {
    final shown = quizzes.take(5).toList();
    return BarChart(
      BarChartData(
        maxY: 100,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= shown.length) return const SizedBox.shrink();
                final title = shown[i].title;
                final label = title.length > 8 ? '${title.substring(0, 8)}…' : title;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(label, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < shown.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: shown[i].submissionRate.clamp(0, 100),
                  color: AppColors.primary,
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
