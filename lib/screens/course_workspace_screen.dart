import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import '../l10n/generated/app_localizations.dart';
import 'assessment_details_screen.dart';

/// One class+subject's workspace — mirrors the web app's CourseWorkspace
/// page: quizzes open now / upcoming for this specific enrollment, and a
/// "Results" list of past submissions grouped by quiz (best attempt shown).
class CourseWorkspaceScreen extends StatefulWidget {
  final String classId;
  final String subjectId;
  final String subjectName;
  final String className;
  final IconData subjectIcon;
  final Color subjectColor;

  const CourseWorkspaceScreen({
    super.key,
    required this.classId,
    required this.subjectId,
    required this.subjectName,
    required this.className,
    required this.subjectIcon,
    required this.subjectColor,
  });

  @override
  State<CourseWorkspaceScreen> createState() => _CourseWorkspaceScreenState();
}

class _WorkspaceData {
  final List<Assessment> quizzes;
  final List<HistoryItem> results;
  const _WorkspaceData({required this.quizzes, required this.results});
}

class _QuizResultGroup {
  final String quizId;
  final String quizTitle;
  final List<HistoryItem> attempts;
  final HistoryItem best;
  const _QuizResultGroup({
    required this.quizId,
    required this.quizTitle,
    required this.attempts,
    required this.best,
  });
}

class _CourseWorkspaceScreenState extends State<CourseWorkspaceScreen> {
  late Future<_WorkspaceData> _future;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_WorkspaceData> _load() async {
    final repo = AppRepository.instance;
    final quizzes = await repo.fetchAssessmentsForClass(
      classId: widget.classId,
      subjectId: widget.subjectId,
    );
    final results = await repo.fetchHistoryForClass(
      classId: widget.classId,
      subjectId: widget.subjectId,
    );
    return _WorkspaceData(quizzes: quizzes, results: results);
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

  List<_QuizResultGroup> _groupResults(List<HistoryItem> items) {
    final byQuiz = <String, List<HistoryItem>>{};
    for (final h in items) {
      byQuiz.putIfAbsent(h.quizId, () => []).add(h);
    }
    return byQuiz.entries
        .map(
          (e) => _QuizResultGroup(
            quizId: e.key,
            quizTitle: e.value.first.quizTitle,
            attempts: e.value,
            best: e.value.reduce((a, b) => a.score > b.score ? a : b),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName),
        leading: const BackButton(),
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<_WorkspaceData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  children: [
                    SkeletonBox(height: 60, radius: 16),
                    SizedBox(height: 16),
                    SkeletonBox(height: 120, radius: 20),
                    SizedBox(height: 12),
                    SkeletonBox(height: 120, radius: 20),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return ErrorStateView(
                message: describeApiError(snapshot.error!),
                onRetry: _retry,
              );
            }
            final data = snapshot.data!;
            final openQuizzes = data.quizzes
                .where((q) => q.isOpen && !q.isClosed)
                .toList();
            final upcomingQuizzes = data.quizzes
                .where((q) => q.isUpcoming)
                .toList();
            final groups = _groupResults(data.results);

            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Text(
                    widget.className,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text(
                            '${l.quizzesTabLabel} (${openQuizzes.length + upcomingQuizzes.length})',
                          ),
                          selected: !_showResults,
                          onSelected: (_) =>
                              setState(() => _showResults = false),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: !_showResults
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            side: BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: Text(
                            '${l.resultsTabLabel} (${groups.length})',
                          ),
                          selected: _showResults,
                          onSelected: (_) =>
                              setState(() => _showResults = true),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: _showResults
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            side: BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!_showResults)
                    ..._buildQuizzesTab(context, openQuizzes, upcomingQuizzes)
                  else
                    ..._buildResultsTab(context, groups),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildQuizzesTab(
    BuildContext context,
    List<Assessment> open,
    List<Assessment> upcoming,
  ) {
    final l = AppLocalizations.of(context);
    Widget quizCard(Assessment a) => QuizCard(
      icon: widget.subjectIcon,
      color: widget.subjectColor,
      title: a.title,
      subjectLabel: a.className,
      duration: a.duration,
      totalQuestions: a.totalQuestions,
      isUpcoming: a.isUpcoming,
      isClosed: a.isClosed,
      attemptsExhausted: a.attemptsExhausted,
      startAt: a.startAt,
      onTap: () => Navigator.of(
        context,
      ).push(fadeRoute(AssessmentDetailsScreen(assessmentId: a.id))),
    );

    return [
      Text(l.openNowLabel, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      if (open.isEmpty)
        Text(
          l.noOpenQuizzesForCourse,
          style: Theme.of(context).textTheme.bodyMedium,
        )
      else
        ...open.map(quizCard),
      if (upcoming.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text(l.upcomingLabel, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...upcoming.map(quizCard),
      ],
    ];
  }

  List<Widget> _buildResultsTab(
    BuildContext context,
    List<_QuizResultGroup> groups,
  ) {
    final l = AppLocalizations.of(context);
    if (groups.isEmpty) {
      return [
        EmptyState(
          icon: Icons.description_outlined,
          title: l.noCompletedYet,
          subtitle: l.noCompletedYetSubtitle,
        ),
      ];
    }
    return groups
        .map(
          (g) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: softCardDecoration(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBadge(
                    icon: Icons.check_circle_rounded,
                    color: g.best.color,
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.quizTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.lastSubmittedLabel(
                            formatDisplayDate(
                              g.best.submittedAt,
                              withTime: true,
                            ),
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l.attemptsCountLabel(g.attempts.length)} · ${l.scoreOfTotalPercentLabel(g.best.score, g.best.totalPoints, g.best.percentage.round())}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  StatusPill(
                    label: g.best.passed ? l.passed : l.notPassed,
                    color: g.best.color,
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }
}
