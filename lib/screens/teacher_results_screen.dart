import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'answer_review_screen.dart';

class TeacherResultsScreen extends StatefulWidget {
  final bool embedded;
  const TeacherResultsScreen({super.key, this.embedded = false});

  @override
  State<TeacherResultsScreen> createState() => _TeacherResultsScreenState();
}

class _TeacherResultsScreenState extends State<TeacherResultsScreen> {
  String _query = '';
  String _filter = 'All';
  late Future<RepoResult<List<TeacherResult>>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchAllResults();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RepoResult<List<TeacherResult>>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
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
          return widget.embedded ? loading : Scaffold(body: SafeArea(child: loading));
        }
        return _buildBody(context, snapshot.data!);
      },
    );
  }

  Future<void> _openAnswerReview(BuildContext context, TeacherResult r) async {
    final res = await AppRepository.instance.fetchAssessment(r.quizId);
    if (!context.mounted) return;
    Navigator.of(context).push(fadeRoute(AnswerReviewScreen(
      selections: r.answers,
      questions: res.data.questions,
      title: '${r.studentName} · ${r.subjectName}',
    )));
  }

  Widget _buildBody(BuildContext context, RepoResult<List<TeacherResult>> result) {
    final filtered = result.data.where((r) {
      final q = _query.toLowerCase();
      final matchesQuery = r.studentName.toLowerCase().contains(q) || r.subjectName.toLowerCase().contains(q);
      final matchesFilter = _filter == 'All' || r.level.label == _filter;
      return matchesQuery && matchesFilter;
    }).toList();

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text('All Results', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Every student\'s quiz result across all classes', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),
        if (result.isDemo) const DemoModeBanner(),
        const SizedBox(height: 4),

        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Search by student or subject...',
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 14),

        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['All', 'Excellent', 'Good', 'Average', 'Beginner'].map((f) {
              final selected = _filter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: selected,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 12.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill), side: const BorderSide(color: AppColors.border)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        if (filtered.isEmpty)
          const EmptyState(
            icon: Icons.fact_check_outlined,
            title: 'No results found',
            subtitle: 'Try a different search term or filter.',
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
                                const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textMuted),
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
    return Scaffold(body: SafeArea(child: body));
  }
}
