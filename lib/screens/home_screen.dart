import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'subjects_screen.dart';
import 'classrooms_screen.dart';
import 'assessment_details_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

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
  _DashboardData? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = AppRepository.instance;
    final profile = await repo.fetchProfile();
    final subjects = await repo.fetchSubjects();
    final assessments = await repo.fetchUpcomingAssessments();
    final history = await repo.fetchHistory();
    final data = _DashboardData(
      studentName: profile.data.name,
      subjects: subjects.data,
      upcoming: assessments.data,
      history: history.data,
      isDemo:
          profile.isDemo ||
          subjects.isDemo ||
          assessments.isDemo ||
          history.isDemo,
    );
    if (mounted) setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) {
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
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: _DashboardBody(data: data),
    );
  }
}

class _DashboardData {
  final String studentName;
  final List<Subject> subjects;
  final List<Assessment> upcoming;
  final List<HistoryItem> history;
  final bool isDemo;
  _DashboardData({
    required this.studentName,
    required this.subjects,
    required this.upcoming,
    required this.history,
    required this.isDemo,
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
    final completedTotal = data.subjects.fold<int>(
      0,
      (a, s) => a + s.completed,
    );
    final totalAssessments = data.subjects.fold<int>(
      0,
      (a, s) => a + s.totalAssessments,
    );
    final progress = totalAssessments == 0
        ? 0.0
        : completedTotal / totalAssessments;
    final nextAssessment = data.upcoming.isNotEmpty
        ? data.upcoming.first
        : null;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        if (data.isDemo) const DemoModeBanner(),
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
                    'Welcome back 👋',
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
                    const Text(
                      'Your Learning Progress',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$completedTotal of $totalAssessments completed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      onPressed: nextAssessment == null
                          ? null
                          : () => Navigator.of(context).push(
                              fadeRoute(
                                AssessmentDetailsScreen(
                                  assessmentId: nextAssessment.id,
                                ),
                              ),
                            ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontSize: 13),
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
        const SizedBox(height: 26),

        SectionHeader(
          title: 'Upcoming Assessments',
          actionLabel: 'See all',
          onAction: () {},
        ),
        const SizedBox(height: 12),
        if (nextAssessment == null)
          const EmptyState(
            icon: Icons.event_available_outlined,
            title: 'All caught up',
            subtitle: 'No upcoming pre-study assessments right now.',
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: softCardDecoration(),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () => Navigator.of(context).push(
                fadeRoute(
                  AssessmentDetailsScreen(assessmentId: nextAssessment.id),
                ),
              ),
              child: Row(
                children: [
                  IconBadge(
                    icon: nextAssessment.icon,
                    color: nextAssessment.color,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextAssessment.subject,
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
                              '${nextAssessment.duration} min · ${nextAssessment.totalQuestions} questions'
                              '${nextAssessment.endAt != null ? ' · Due ${formatDisplayDate(nextAssessment.endAt, withTime: true)}' : ''}',
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
        const SizedBox(height: 26),

        SectionHeader(
          title: 'Assigned Subjects',
          actionLabel: 'View all',
          onAction: () {},
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: data.subjects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final s = data.subjects[i];
              return Container(
                width: 150,
                padding: const EdgeInsets.all(16),
                decoration: softCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconBadge(icon: s.icon, color: s.color, size: 40),
                    const Spacer(),
                    Text(
                      s.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${s.completed}/${s.totalAssessments} done',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 26),

        SectionHeader(
          title: 'Completed Assessments',
          actionLabel: 'History',
          onAction: () {},
        ),
        const SizedBox(height: 12),
        if (data.history.isEmpty)
          const EmptyState(
            icon: Icons.description_outlined,
            title: 'No completed assessments yet',
            subtitle: 'Finished pre-study quizzes will appear here.',
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
