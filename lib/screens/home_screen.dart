import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'my_course_screen.dart';
import 'quizzes_screen.dart';
import 'course_workspace_screen.dart';
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
    MyCourseScreen(embedded: true),
    QuizzesScreen(embedded: true),
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
    final allAssessments = await repo.fetchAllAssessments();
    final classes = await repo.fetchSubjects();
    final unreadNotifications = await repo.fetchUnreadNotificationsCount();
    final progress = AssessmentProgress.fromAssessments(allAssessments);
    return _DashboardData(
      studentName: profile.name,
      stats: stats,
      classes: classes,
      unreadNotifications: unreadNotifications,
      progress: progress,
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
          return ErrorStateView(
            message: describeApiError(snapshot.error!),
            onRetry: _retry,
          );
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          child: _DashboardBody(
            data: snapshot.data!,
            onNotificationsChanged: _retry,
          ),
        );
      },
    );
  }
}

class _DashboardData {
  final String studentName;
  final StudentDashboardStats stats;
  final List<Subject> classes;
  final int unreadNotifications;
  final AssessmentProgress progress;
  _DashboardData({
    required this.studentName,
    required this.stats,
    required this.classes,
    required this.unreadNotifications,
    required this.progress,
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
  final VoidCallback onNotificationsChanged;
  const _DashboardBody({
    required this.data,
    required this.onNotificationsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final completedTotal = data.progress.completed;
    final totalAssessments = data.progress.total;
    final progress = data.progress.percent;
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
              onTap: () async {
                await Navigator.of(
                  context,
                ).push(fadeRoute(const NotificationsScreen()));
                if (context.mounted) onNotificationsChanged();
              },
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
                    if (data.unreadNotifications > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          constraints: const BoxConstraints(
                            minWidth: 17,
                            minHeight: 17,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: AppColors.surface,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            data.unreadNotifications > 9
                                ? '9+'
                                : '${data.unreadNotifications}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
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
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
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
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
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
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.check_circle_rounded,
                    label: l.completedChartLabel,
                    value: '${data.progress.completed}',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.pending_actions_rounded,
                    label: l.todoChartLabel,
                    value: '${data.progress.todo}',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 26),

        SectionHeader(
          title: l.myClassesTitle,
          actionLabel: l.viewAll,
          onAction: () =>
              Navigator.of(context).push(fadeRoute(const MyCourseScreen())),
        ),
        const SizedBox(height: 12),
        if (data.classes.isEmpty)
          Text(
            l.notEnrolledInAnyClasses,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          ...data.classes
              .take(2)
              .map(
                (s) => _ClassCard(
                  subject: s,
                  onTap: () => Navigator.of(context).push(
                    fadeRoute(
                      CourseWorkspaceScreen(
                        classId: s.classId,
                        subjectId: s.id,
                        subjectName: s.name,
                        className: s.className,
                        subjectIcon: s.icon,
                        subjectColor: s.color,
                      ),
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 26),

        if (data.stats.recentQuizzes.isNotEmpty) ...[
          SectionHeader(
            title: l.newlyPublishedQuizzes,
            actionLabel: l.viewAll,
            onAction: () =>
                Navigator.of(context).push(fadeRoute(const QuizzesScreen())),
          ),
          const SizedBox(height: 12),
          ...data.stats.recentQuizzes
              .take(2)
              .map(
                (q) => QuizCard(
                  icon: q.icon,
                  color: q.color,
                  title: q.title,
                  subjectLabel: '${q.subject} · ${q.className}',
                  duration: q.duration,
                  totalQuestions: q.totalQuestions,
                  isUpcoming: q.isUpcoming,
                  isClosed: q.isClosed,
                  attemptsExhausted: q.attemptsExhausted,
                  startAt: q.startAt,
                  showNewBadge: true,
                  onTap: () => Navigator.of(context).push(
                    fadeRoute(AssessmentDetailsScreen(assessmentId: q.id)),
                  ),
                ),
              ),
          const SizedBox(height: 26),
        ],

        SectionHeader(
          title: l.scheduleSectionTitle,
          actionLabel: l.viewAll,
          onAction: () =>
              Navigator.of(context).push(fadeRoute(const ScheduleScreen())),
        ),
        const SizedBox(height: 12),
        const ScheduleScreen(embedded: true),
      ],
    );
  }
}

/// One "My Classes" card — mirrors the web dashboard's class card (code
/// badge, active tag, subject/class metadata, quizzes-completed progress
/// bar, "Open Workspace" action).
class _ClassCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;
  const _ClassCard({required this.subject, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final total = subject.totalAssessments;
    final completed = subject.completed;
    final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: softCardDecoration(),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    subject.code,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                StatusPill(label: l.activeLabel, color: AppColors.success),
              ],
            ),
            const SizedBox(height: 12),
            Text(subject.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              subject.className,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border),
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: Column(
                children: [
                  _metaRow(
                    context,
                    Icons.menu_book_rounded,
                    l.subjectCodeLabel,
                    subject.code,
                  ),
                  const SizedBox(height: 8),
                  _metaRow(
                    context,
                    Icons.groups_rounded,
                    l.classGroupLabel,
                    subject.className,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.quizzesCompletedLabel,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '$completed/$total',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.folder_open_rounded, size: 18),
                label: Text(l.openWorkspace),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
