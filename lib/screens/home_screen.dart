import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'subjects_screen.dart';
import 'classrooms_screen.dart';
import 'assessment_details_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'schedule_screen.dart';
import '../l10n/generated/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final _pages = const [
    _HomeDashboardBody(),
    ClassRoomsScreen(embedded: true),
    _AssessmentsPlaceholder(),
    HistoryScreen(embedded: true),
    ProfileScreen(embedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_navIndex]),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

class _AssessmentsPlaceholder extends StatelessWidget {
  const _AssessmentsPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const SubjectsScreen(embedded: true, jumpToAssessments: true);
  }
}

class _HomeDashboardBody extends StatefulWidget {
  const _HomeDashboardBody();

  @override
  State<_HomeDashboardBody> createState() => _HomeDashboardBodyState();
}

class _HomeDashboardBodyState extends State<_HomeDashboardBody> {
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DashboardData> _load() async {
    final repo = AppRepository.instance;
    final profile = await repo.fetchProfile();
    final stats = await repo.fetchStudentDashboard();
    final history = await repo.fetchHistory();
    return _DashboardData(studentName: profile.name, stats: stats, history: history);
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
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: const [
              SkeletonBox(height: 48, radius: 24),
              SizedBox(height: 24),
              SkeletonBox(height: 120, radius: 20),
              SizedBox(height: 24),
              SkeletonBox(height: 90, radius: 20),
              SizedBox(height: 24),
              SkeletonBox(height: 132, radius: 20),
            ],
          );
        }
        if (snapshot.hasError) {
          return ErrorStateView(message: describeApiError(snapshot.error!), onRetry: _retry);
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          child: _DashboardBody(data: snapshot.data!),
        );
      },
    );
  }
}

class _DashboardData {
  final String studentName;
  final StudentDashboardStats stats;
  final List<HistoryItem> history;
  _DashboardData({
    required this.studentName,
    required this.stats,
    required this.history,
  });
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

class _DashboardBody extends StatelessWidget {
  final _DashboardData data;
  const _DashboardBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final completedTotal = data.stats.completedCount;
    final totalAssessments = data.stats.completedCount + data.stats.todoCount;
    final progress = totalAssessments == 0
        ? 0.0
        : completedTotal / totalAssessments;
    final nextAssessment = data.stats.dueSoon.isNotEmpty
        ? data.stats.dueSoon.first
        : null;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        // Header: welcome + profile + notifications
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _initials(data.studentName),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.welcomeBack,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    data.studentName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.of(context).push(fadeRoute(const ScheduleScreen())),
              child: Container(
                width: 46,
                height: 46,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(
                context,
              ).push(fadeRoute(const NotificationsScreen())),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textPrimary,
                    ),
                    Positioned(
                      top: 11,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Progress hero card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.yourLearningProgress,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.completedOfTotal(completedTotal, totalAssessments),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (nextAssessment != null)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        onPressed: () => Navigator.of(context).push(
                          fadeRoute(
                            AssessmentDetailsScreen(
                              assessmentId: nextAssessment.id,
                            ),
                          ),
                        ),
                        child: Text(
                          l.continueLabel,
                          style: const TextStyle(fontSize: 13),
                        ),
                      )
                    else
                      Text(
                        totalAssessments == 0
                            ? l.noAssessmentsAssignedYet
                            : l.allCaughtUpNothingDue,
                        style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                      ),
                  ],
                ),
              ),
              CircularPercentIndicator(
                radius: 38,
                lineWidth: 8,
                percent: progress.clamp(0, 1),
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                progressColor: Colors.white,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Completed vs. to-do split, at a glance.
        if (totalAssessments == 0)
          EmptyState(
            icon: Icons.bar_chart_rounded,
            title: l.noProgressYet,
            subtitle: l.noProgressYetSubtitle,
          )
        else
          Container(
            height: 160,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            decoration: softCardDecoration(),
            child: _ProgressBarChart(
              completed: data.stats.completedCount,
              todo: data.stats.todoCount,
              completedLabel: l.completedChartLabel,
              todoLabel: l.todoChartLabel,
            ),
          ),
        const SizedBox(height: 26),

        SectionHeader(title: l.announcementsTitle),
        const SizedBox(height: 12),
        if (data.stats.announcements.isEmpty)
          EmptyState(
            icon: Icons.campaign_outlined,
            title: l.noAnnouncements,
            subtitle: l.noAnnouncementsSubtitle,
          )
        else
          ...data.stats.announcements
              .take(3)
              .map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: softCardDecoration(),
                    child: Row(
                      children: [
                        IconBadge(
                          icon: Icons.campaign_rounded,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.message,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${a.teacherName} · ${a.time}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 26),

        SectionHeader(
          title: l.upcomingAssessments,
          actionLabel: l.seeAll,
          onAction: () => Navigator.of(
            context,
          ).push(fadeRoute(const SubjectsScreen(jumpToAssessments: true))),
        ),
        const SizedBox(height: 12),
        if (data.stats.dueSoon.isEmpty)
          EmptyState(
            icon: Icons.event_available_outlined,
            title: l.allCaughtUp,
            subtitle: l.noUpcomingSubtitle,
          )
        else
          ...data.stats.dueSoon.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: softCardDecoration(),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () => Navigator.of(context).push(
                    fadeRoute(AssessmentDetailsScreen(assessmentId: a.id)),
                  ),
                  child: Row(
                    children: [
                      IconBadge(icon: a.icon, color: a.color),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.subject,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 14,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l.durationQuestionsDue(
                                    a.duration,
                                    a.totalQuestions,
                                    a.endAt != null ? l.dueSuffix(formatDisplayDate(a.endAt, withTime: true)) : '',
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 26),

        SectionHeader(
          title: l.enrolledSubjects,
          actionLabel: l.viewAll,
          onAction: () =>
              Navigator.of(context).push(fadeRoute(const SubjectsScreen())),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: softCardDecoration(),
          child: Row(
            children: [
              IconBadge(
                icon: Icons.menu_book_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l.subjectsEnrolledCount(data.stats.enrolledSubjectsCount),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),

        SectionHeader(
          title: l.completedAssessments,
          actionLabel: l.historyAction,
          onAction: () {},
        ),
        const SizedBox(height: 12),
        if (data.history.isEmpty)
          EmptyState(
            icon: Icons.description_outlined,
            title: l.noCompletedYet,
            subtitle: l.noCompletedYetSubtitle,
          )
        else
          ...data.history
              .take(2)
              .map(
                (h) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: softCardDecoration(),
                    child: Row(
                      children: [
                        IconBadge(
                          icon: Icons.check_circle_rounded,
                          color: h.color,
                          size: 42,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h.quizTitle.isNotEmpty
                                    ? h.quizTitle
                                    : h.subject,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                formatDisplayDate(h.submittedAt),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        StatusPill(
                          label: '${h.percentage.round()}%',
                          color: h.color,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

class _ProgressBarChart extends StatelessWidget {
  final int completed;
  final int todo;
  final String completedLabel;
  final String todoLabel;
  const _ProgressBarChart({
    required this.completed,
    required this.todo,
    required this.completedLabel,
    required this.todoLabel,
  });

  @override
  Widget build(BuildContext context) {
    final maxY =
        ([completed, todo, 1].reduce((a, b) => a > b ? a : b)).toDouble() * 1.2;
    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final label = value.toInt() == 0 ? completedLabel : todoLabel;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: completed.toDouble(),
                color: AppColors.success,
                width: 32,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: todo.toDouble(),
                color: AppColors.warning,
                width: 32,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
