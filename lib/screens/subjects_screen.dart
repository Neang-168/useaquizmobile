import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'subject_quizzes_screen.dart';

class SubjectsScreen extends StatefulWidget {
  final bool embedded;
  final bool jumpToAssessments;
  final String? classRoomId;
  final String? classRoomName;
  final void Function(Subject)? onSubjectTap;
  const SubjectsScreen({
    super.key,
    this.embedded = false,
    this.jumpToAssessments = false,
    this.classRoomId,
    this.classRoomName,
    this.onSubjectTap,
  });

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  String _query = '';
  String _classFilter = 'All';
  late Future<RepoResult<List<Subject>>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchSubjects(
      classRoomId: widget.classRoomId,
    );
  }

  Future<void> _refresh() async {
    final next = AppRepository.instance.fetchSubjects(
      classRoomId: widget.classRoomId,
    );
    await next;
    if (mounted) setState(() => _future = next);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RepoResult<List<Subject>>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          final loading = ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: const [
              SkeletonBox(height: 60, radius: 16),
              SizedBox(height: 16),
              SkeletonBox(height: 90, radius: 20),
              SizedBox(height: 12),
              SkeletonBox(height: 90, radius: 20),
              SizedBox(height: 12),
              SkeletonBox(height: 90, radius: 20),
            ],
          );
          if (widget.embedded) return loading;
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.classRoomName ?? 'Subjects'),
              leading: const BackButton(),
            ),
            body: SafeArea(top: false, child: loading),
          );
        }
        return _buildBody(context, snapshot.data!);
      },
    );
  }

  Widget _buildBody(BuildContext context, RepoResult<List<Subject>> result) {
    final classNames = [
      'All',
      ...result.data.map((s) => s.className).where((c) => c.isNotEmpty).toSet(),
    ];
    final filtered = result.data.where((s) {
      final matchesQuery = s.name.toLowerCase().contains(_query.toLowerCase());
      final matchesClass = _classFilter == 'All' || s.className == _classFilter;
      return matchesQuery && matchesClass;
    }).toList();

    final body = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          widget.classRoomName ??
              (widget.jumpToAssessments ? 'Assessments' : 'My Subjects'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Explore subjects and their pre-study assessments',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        if (result.isDemo) const DemoModeBanner(),
        const SizedBox(height: 4),

        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Search subjects...',
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 14),

        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: classNames.map((c) {
              final selected = _classFilter == c;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c),
                  selected: selected,
                  onSelected: (_) => setState(() => _classFilter = c),
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        if (filtered.isEmpty)
          const EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No subjects found',
            subtitle: 'Try a different search term or filter.',
          )
        else
          ...filtered.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: softCardDecoration(),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () => widget.onSubjectTap != null
                      ? widget.onSubjectTap!(s)
                      : Navigator.of(context).push(
                          fadeRoute(
                            SubjectQuizzesScreen(
                              subjectId: s.id,
                              subjectName: s.name,
                              subjectIcon: s.icon,
                              subjectColor: s.color,
                            ),
                          ),
                        ),
                  child: Row(
                    children: [
                      IconBadge(icon: s.icon, color: s.color, size: 50),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${s.code} · ${s.className}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: s.totalAssessments == 0
                                    ? 0
                                    : s.completed / s.totalAssessments,
                                minHeight: 6,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation(s.color),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${s.completed}/${s.totalAssessments}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
        title: Text(widget.classRoomName ?? 'Subjects'),
        leading: const BackButton(),
      ),
      body: SafeArea(top: false, child: refreshableBody),
    );
  }
}
