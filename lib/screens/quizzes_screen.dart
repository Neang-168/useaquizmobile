import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import '../l10n/generated/app_localizations.dart';
import 'assessment_details_screen.dart';

/// The student's full quiz list ("Quiz") — mirrors the web app's My Exams &
/// Quizzes page: a Class/Subject filter bar plus search, and a clean
/// [QuizCard] per quiz.
class QuizzesScreen extends StatefulWidget {
  final bool embedded;
  const QuizzesScreen({super.key, this.embedded = false});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  late Future<List<Assessment>> _future;
  String _query = '';
  String? _classFilter;
  String? _subjectFilter;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchAllAssessments();
  }

  void _retry() => setState(() {
    _future = AppRepository.instance.fetchAllAssessments();
  });

  Future<void> _refresh() async {
    final next = AppRepository.instance.fetchAllAssessments();
    try {
      await next;
    } catch (_) {
      // Keep showing the previous list; the indicator just stops spinning.
    }
    if (mounted) setState(() => _future = next);
  }

  List<String> _uniqueValues(
    List<Assessment> quizzes,
    String Function(Assessment) pick,
  ) {
    final seen = <String>{};
    for (final a in quizzes) {
      final v = pick(a);
      if (v.isNotEmpty) seen.add(v);
    }
    final list = seen.toList()..sort();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FutureBuilder<List<Assessment>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          final loading = ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: const [
              SkeletonBox(height: 60, radius: 16),
              SizedBox(height: 16),
              SkeletonBox(height: 150, radius: 20),
              SizedBox(height: 12),
              SkeletonBox(height: 150, radius: 20),
            ],
          );
          if (widget.embedded) return loading;
          return Scaffold(
            appBar: AppBar(
              title: Text(l.quizzesScreenTitle),
              leading: const BackButton(),
            ),
            body: SafeArea(top: false, child: loading),
          );
        }
        if (snapshot.hasError) {
          final error = ErrorStateView(
            message: describeApiError(snapshot.error!),
            onRetry: _retry,
          );
          if (widget.embedded) return error;
          return Scaffold(
            appBar: AppBar(
              title: Text(l.quizzesScreenTitle),
              leading: const BackButton(),
            ),
            body: SafeArea(top: false, child: error),
          );
        }
        return _buildBody(context, snapshot.data!);
      },
    );
  }

  Widget _buildBody(BuildContext context, List<Assessment> quizzes) {
    final l = AppLocalizations.of(context);
    final classOptions = _uniqueValues(quizzes, (a) => a.className);
    final subjectOptions = _uniqueValues(quizzes, (a) => a.subject);

    final q = _query.toLowerCase();
    final filtered = quizzes.where((a) {
      if (_classFilter != null && a.className != _classFilter) return false;
      if (_subjectFilter != null && a.subject != _subjectFilter) return false;
      if (q.isEmpty) return true;
      return a.title.toLowerCase().contains(q);
    }).toList();

    final body = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          l.quizzesScreenTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          l.quizzesScreenSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        if (quizzes.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: FilterDropdown(
                  label: l.filterClassLabel,
                  value: _classFilter,
                  options: classOptions,
                  allLabel: l.allClassesFilter,
                  onChanged: (v) => setState(() => _classFilter = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilterDropdown(
                  label: l.filterSubjectLabel,
                  value: _subjectFilter,
                  options: subjectOptions,
                  allLabel: l.allSubjectsFilter,
                  onChanged: (v) => setState(() => _subjectFilter = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: l.searchQuizzesHint,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],

        if (quizzes.isEmpty)
          EmptyState(
            icon: Icons.quiz_outlined,
            title: l.noQuizzesYet,
            subtitle: l.noQuizzesYetSubtitle,
          )
        else if (filtered.isEmpty)
          EmptyState(
            icon: Icons.search_off_rounded,
            title: l.noQuizzesMatchFilters,
            subtitle: l.tryDifferentSearch,
          )
        else
          ...filtered.map(
            (a) => QuizCard(
              icon: a.icon,
              color: a.color,
              title: a.title,
              subjectLabel: '${a.subject} · ${a.className}',
              duration: a.duration,
              totalQuestions: a.totalQuestions,
              isUpcoming: a.isUpcoming,
              isClosed: a.isClosed,
              attemptsExhausted: a.attemptsExhausted,
              startAt: a.startAt,
              onTap: () => Navigator.of(
                context,
              ).push(fadeRoute(AssessmentDetailsScreen(assessmentId: a.id))),
            ),
          ),
      ],
    );

    final refreshableBody = RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primary,
      child: body,
    );

    if (widget.embedded) return refreshableBody;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.quizzesScreenTitle),
        leading: const BackButton(),
      ),
      body: SafeArea(top: false, child: refreshableBody),
    );
  }
}
