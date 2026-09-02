import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import '../l10n/generated/app_localizations.dart';
import 'subject_quizzes_screen.dart';

class SubjectsScreen extends StatefulWidget {
  final String? classRoomId;
  final String? classRoomName;
  final void Function(Subject)? onSubjectTap;
  const SubjectsScreen({
    super.key,
    this.classRoomId,
    this.classRoomName,
    this.onSubjectTap,
  });

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  String _query = '';
  // null means "All" — kept locale-independent since the visible chip label
  // ("All" / translated equivalent) can change when the user switches language.
  String? _classFilter;
  late Future<List<Subject>> _future;

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
    try {
      await next;
    } catch (_) {
      // Keep showing the previous list; the indicator just stops spinning.
    }
    if (mounted) setState(() => _future = next);
  }

  void _retry() => setState(() {
    _future = AppRepository.instance.fetchSubjects(
      classRoomId: widget.classRoomId,
    );
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FutureBuilder<List<Subject>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
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
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.classRoomName ?? l.subjectsAppBarTitle),
              leading: const BackButton(),
            ),
            body: SafeArea(top: false, child: loading),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.classRoomName ?? l.subjectsAppBarTitle),
              leading: const BackButton(),
            ),
            body: SafeArea(
              top: false,
              child: ErrorStateView(
                message: describeApiError(snapshot.error!),
                onRetry: _retry,
              ),
            ),
          );
        }
        return _buildBody(context, snapshot.data!);
      },
    );
  }

  Widget _buildBody(BuildContext context, List<Subject> subjects) {
    final l = AppLocalizations.of(context);
    final classNames = subjects
        .map((s) => s.className)
        .where((c) => c.isNotEmpty)
        .toSet();
    final filtered = subjects.where((s) {
      final matchesQuery = s.name.toLowerCase().contains(_query.toLowerCase());
      final matchesClass = _classFilter == null || s.className == _classFilter;
      return matchesQuery && matchesClass;
    }).toList();

    final body = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          widget.classRoomName ?? l.mySubjects,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          l.exploreSubjectsSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),

        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: l.searchSubjectsHint,
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 14),

        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [null, ...classNames].map((c) {
              final selected = _classFilter == c;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c ?? l.allFilter),
                  selected: selected,
                  onSelected: (_) => setState(() => _classFilter = c),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    side: BorderSide(color: AppColors.border),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        if (filtered.isEmpty)
          EmptyState(
            icon: Icons.search_off_rounded,
            title: l.noSubjectsFound,
            subtitle: l.tryDifferentSearch,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classRoomName ?? l.subjectsAppBarTitle),
        leading: const BackButton(),
      ),
      body: SafeArea(top: false, child: refreshableBody),
    );
  }
}
