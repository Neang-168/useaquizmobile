import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'assessment_details_screen.dart';

class SubjectQuizzesScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final IconData subjectIcon;
  final Color subjectColor;
  const SubjectQuizzesScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.subjectIcon,
    required this.subjectColor,
  });

  @override
  State<SubjectQuizzesScreen> createState() => _SubjectQuizzesScreenState();
}

class _SubjectQuizzesScreenState extends State<SubjectQuizzesScreen> {
  late Future<List<Assessment>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchAssessmentsBySubject(
      widget.subjectId,
    );
  }

  Future<void> _refresh() async {
    final next = AppRepository.instance.fetchAssessmentsBySubject(
      widget.subjectId,
    );
    try {
      await next;
    } catch (_) {
      // Keep showing the previous list; the indicator just stops spinning.
    }
    if (mounted) setState(() => _future = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName),
        leading: const BackButton(),
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<Assessment>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorStateView(
                message: describeApiError(snapshot.error!),
                onRetry: () => setState(() {
                  _future = AppRepository.instance.fetchAssessmentsBySubject(widget.subjectId);
                }),
              );
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SkeletonBox(height: 90, radius: 20),
                    SizedBox(height: 12),
                    SkeletonBox(height: 90, radius: 20),
                  ],
                ),
              );
            }
            final quizzes = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Text(
                    'All Quiz',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pre-study quizzes for ${widget.subjectName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  if (quizzes.isEmpty)
                    const EmptyState(
                      icon: Icons.quiz_outlined,
                      title: 'No quizzes yet',
                      subtitle: 'This subject has no pre-study quizzes yet.',
                    )
                  else
                    ...quizzes.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: softCardDecoration(),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            onTap: () => Navigator.of(context).push(
                              fadeRoute(
                                AssessmentDetailsScreen(assessmentId: a.id),
                              ),
                            ),
                            child: Row(
                              children: [
                                IconBadge(
                                  icon: widget.subjectIcon,
                                  color: widget.subjectColor,
                                  size: 50,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.title.isNotEmpty
                                            ? a.title
                                            : a.subject,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${a.totalQuestions} questions · ${a.duration} min'
                                        '${a.endAt != null ? ' · Due ${formatDisplayDate(a.endAt, withTime: true)}' : ''}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
