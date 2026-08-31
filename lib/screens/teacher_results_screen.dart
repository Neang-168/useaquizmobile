import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import '../l10n/generated/app_localizations.dart';
import 'answer_review_screen.dart';

class TeacherResultsScreen extends StatefulWidget {
  final bool embedded;
  const TeacherResultsScreen({super.key, this.embedded = false});

  @override
  State<TeacherResultsScreen> createState() => _TeacherResultsScreenState();
}

class _TeacherResultsScreenState extends State<TeacherResultsScreen> {
  String _query = '';
  PerformanceLevel? _filter;
  late Future<List<TeacherResult>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchAllResults();
  }

  void _retry() => setState(() => _future = AppRepository.instance.fetchAllResults());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TeacherResult>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          final loading = ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: const [
              SkeletonBox(height: 60, radius: 16),
              SizedBox(height: 16),
              SkeletonBox(height: 84, radius: 20),
              SizedBox(height: 12),
              SkeletonBox(height: 84, radius: 20),
            ],
          );
          if (widget.embedded) return loading;
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context).resultsAppBarTitle), leading: const BackButton()),
            body: SafeArea(top: false, child: loading),
          );
        }
        if (snapshot.hasError) {
          final error = ErrorStateView(message: describeApiError(snapshot.error!), onRetry: _retry);
          if (widget.embedded) return error;
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context).resultsAppBarTitle), leading: const BackButton()),
            body: SafeArea(top: false, child: error),
          );
        }
        return _buildBody(context, snapshot.data!);
      },
    );
  }

  Future<void> _openAnswerReview(BuildContext context, TeacherResult r) async {
    final assessment = await AppRepository.instance.fetchAssessment(r.quizId);
    if (!context.mounted) return;
    Navigator.of(context).push(fadeRoute(AnswerReviewScreen(
      selections: r.answers,
      questions: assessment.questions,
      title: '${r.studentName} · ${r.subjectName}',
    )));
  }

  Widget _buildBody(BuildContext context, List<TeacherResult> results) {
    final l = AppLocalizations.of(context);
    final filtered = results.where((r) {
      final q = _query.toLowerCase();
      final matchesQuery = r.studentName.toLowerCase().contains(q) || r.subjectName.toLowerCase().contains(q);
      final matchesFilter = _filter == null || r.level == _filter;
      return matchesQuery && matchesFilter;
    }).toList();

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(l.allResultsTitle, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(l.everyStudentResultSubtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),

        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: l.searchStudentSubjectHint,
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 14),

        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [null, ...PerformanceLevel.values].map((f) {
              final selected = _filter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f?.label ?? l.allFilter),
                  selected: selected,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 12.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill), side: BorderSide(color: AppColors.border)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        if (filtered.isEmpty)
          EmptyState(
            icon: Icons.fact_check_outlined,
            title: l.noResultsFound,
            subtitle: l.tryDifferentSearch,
          )
        else
          ...filtered.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: softCardDecoration(),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    onTap: r.answers.isEmpty ? null : () => _openAnswerReview(context, r),
                    child: Row(
                      children: [
                        IconBadge(icon: Icons.person_rounded, color: r.color, size: 48),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.studentName, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text('${r.subjectName} · ${r.className}', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 2),
                              Row(children: [
                                Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(formatDisplayDate(r.submittedAt), style: Theme.of(context).textTheme.bodyMedium),
                              ]),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${r.percentage.round()}%', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            StatusPill(label: r.level.label, color: r.color),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: Text(l.resultsAppBarTitle), leading: const BackButton()),
      body: SafeArea(top: false, child: body),
    );
  }
}
