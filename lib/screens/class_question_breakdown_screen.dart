import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';

class _QuestionStat {
  final Question question;
  final int correctCount;
  final int total;
  const _QuestionStat({required this.question, required this.correctCount, required this.total});

  double get correctRatio => total == 0 ? 0 : correctCount / total;
}

class _Breakdown {
  final List<_QuestionStat> stats;
  final int studentCount;
  final bool isDemo;

  /// Whether a breakdown is even possible for this data. The live
  /// `/teacher/quizzes/{id}/scores` endpoint only returns aggregate
  /// mcq/essay scores per submission — no per-question answer detail exists
  /// anywhere in the API for a teacher to fetch — so this is only ever true
  /// in demo mode, where [TeacherResult.answers] is populated locally.
  final bool availableLive;
  const _Breakdown({required this.stats, required this.studentCount, required this.isDemo, this.availableLive = true});
}

/// Aggregates every student's answers for a subject into per-question
/// right/wrong counts, so a teacher can spot which topics need re-teaching —
/// reuses the same [TeacherResult.answers] already fetched for the flat
/// results list, just grouped by question instead of by student. Demo-mode
/// only — see [_Breakdown.availableLive].
class ClassQuestionBreakdownScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  const ClassQuestionBreakdownScreen({super.key, required this.subjectId, required this.subjectName});

  @override
  State<ClassQuestionBreakdownScreen> createState() => _ClassQuestionBreakdownScreenState();
}

class _ClassQuestionBreakdownScreenState extends State<ClassQuestionBreakdownScreen> {
  late Future<_Breakdown> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Breakdown> _load() async {
    final resultsRes = await AppRepository.instance.fetchAllResults(subjectId: widget.subjectId);

    // The live scores endpoint has no per-question answer data at all, so a
    // breakdown can only ever be built in demo mode (see [_Breakdown.availableLive]).
    if (!resultsRes.isDemo) {
      return const _Breakdown(stats: [], studentCount: 0, isDemo: false, availableLive: false);
    }

    final results = resultsRes.data.where((r) => r.quizId.isNotEmpty && r.answers.isNotEmpty).toList();
    if (results.isEmpty) {
      return const _Breakdown(stats: [], studentCount: 0, isDemo: true);
    }

    // Every quiz under a subject shares the same question set in this demo
    // data, so any one result's quiz gives the canonical question list.
    final assessmentRes = await AppRepository.instance.fetchAssessment(results.first.quizId);
    final questions = assessmentRes.data.questions;

    final stats = List.generate(questions.length, (i) {
      final q = questions[i];
      final correctIds = q.options.where((o) => o.isCorrect).map((o) => o.id).toSet();
      final correct = results.where((r) => i < r.answers.length && correctIds.contains(r.answers[i])).length;
      return _QuestionStat(question: q, correctCount: correct, total: results.length);
    })
      ..sort((a, b) => a.correctRatio.compareTo(b.correctRatio));

    return _Breakdown(stats: stats, studentCount: results.length, isDemo: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subjectName), leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: FutureBuilder<_Breakdown>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Couldn\'t load question breakdown',
                subtitle: '${snapshot.error}',
              );
            }
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Column(children: [
                  SkeletonBox(height: 90, radius: 20),
                  SizedBox(height: 12),
                  SkeletonBox(height: 90, radius: 20),
                ]),
              );
            }
            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                if (data.isDemo) const DemoModeBanner(),
                Text('Question Breakdown', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  !data.availableLive
                      ? 'Not available for live quiz data yet.'
                      : data.studentCount == 0
                          ? 'No submitted results for this subject yet.'
                          : 'Across ${data.studentCount} student${data.studentCount == 1 ? '' : 's'} — most-missed questions first, so you can see what to re-teach.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                if (!data.availableLive)
                  const EmptyState(
                    icon: Icons.info_outline_rounded,
                    title: 'Per-question breakdown unavailable',
                    subtitle:
                        'The API only returns each student\'s overall score, not their answer to every question, so this view can\'t be built from live data.',
                  )
                else if (data.stats.isEmpty)
                  const EmptyState(
                    icon: Icons.quiz_outlined,
                    title: 'Nothing to show yet',
                    subtitle: 'Once students submit this subject\'s quizzes, their answers will be summarized here.',
                  )
                else
                  ...data.stats.asMap().entries.map((entry) {
                    final i = entry.key;
                    final stat = entry.value;
                    final pct = (stat.correctRatio * 100).round();
                    final needsReview = stat.correctRatio < 0.5;
                    final barColor = needsReview ? AppColors.danger : AppColors.success;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: softCardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Question ${i + 1}',
                                    style: TextStyle(color: AppColors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600)),
                                if (needsReview) const StatusPill(label: 'Needs review', color: AppColors.danger),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(stat.question.title, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Text(
                                'Correct answer: ${stat.question.options.where((o) => o.isCorrect).map((o) => o.text).join(', ')}',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: stat.correctRatio,
                                minHeight: 8,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation(barColor),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('${stat.correctCount}/${stat.total} students correct ($pct%)',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}
