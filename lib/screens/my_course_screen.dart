import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import '../l10n/generated/app_localizations.dart';
import 'course_workspace_screen.dart';

/// The student's full list of enrolled classes ("My Course") — mirrors the
/// web app's My Courses page: a Class/Subject/Shift/Academic Year filter
/// bar plus search, and a clean card per enrollment (code + shift badge,
/// teacher, academic year, quiz progress, "View Quizzes" action) that opens
/// the class's [CourseWorkspaceScreen].
class MyCourseScreen extends StatefulWidget {
  final bool embedded;
  const MyCourseScreen({super.key, this.embedded = false});

  @override
  State<MyCourseScreen> createState() => _MyCourseScreenState();
}

class _MyCourseScreenState extends State<MyCourseScreen> {
  late Future<List<Subject>> _future;
  String _query = '';
  String? _classFilter;
  String? _subjectFilter;
  String? _shiftFilter;
  String? _academicYearFilter;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchSubjects();
  }

  void _retry() => setState(() {
    _future = AppRepository.instance.fetchSubjects();
  });

  Future<void> _refresh() async {
    final next = AppRepository.instance.fetchSubjects();
    try {
      await next;
    } catch (_) {
      // Keep showing the previous list; the indicator just stops spinning.
    }
    if (mounted) setState(() => _future = next);
  }

  List<String> _uniqueValues(
    List<Subject> courses,
    String Function(Subject) pick,
  ) {
    final seen = <String>{};
    for (final c in courses) {
      final v = pick(c);
      if (v.isNotEmpty) seen.add(v);
    }
    final list = seen.toList()..sort();
    return list;
  }

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
              SkeletonBox(height: 220, radius: 20),
              SizedBox(height: 12),
              SkeletonBox(height: 220, radius: 20),
            ],
          );
          if (widget.embedded) return loading;
          return Scaffold(
            appBar: AppBar(
              title: Text(l.myCourseTitle),
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
              title: Text(l.myCourseTitle),
              leading: const BackButton(),
            ),
            body: SafeArea(top: false, child: error),
          );
        }
        return _buildBody(context, snapshot.data!);
      },
    );
  }

  Widget _buildBody(BuildContext context, List<Subject> courses) {
    final l = AppLocalizations.of(context);
    final classOptions = _uniqueValues(courses, (c) => c.className);
    final subjectOptions = _uniqueValues(courses, (c) => c.name);
    final shiftOptions = _uniqueValues(courses, (c) => c.shift);
    final academicYearOptions = _uniqueValues(courses, (c) => c.academicYear);

    final q = _query.toLowerCase();
    final filtered = courses.where((c) {
      if (_classFilter != null && c.className != _classFilter) return false;
      if (_subjectFilter != null && c.name != _subjectFilter) return false;
      if (_shiftFilter != null && c.shift != _shiftFilter) return false;
      if (_academicYearFilter != null &&
          c.academicYear != _academicYearFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) ||
          c.className.toLowerCase().contains(q) ||
          c.teacher.toLowerCase().contains(q);
    }).toList();

    final body = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          l.myCourseTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          courses.isEmpty
              ? l.myCourseSubtitle
              : l.courseCountLabel(filtered.length, courses.length),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        if (courses.isNotEmpty) ...[
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
          Row(
            children: [
              Expanded(
                child: FilterDropdown(
                  label: l.filterShiftLabel,
                  value: _shiftFilter,
                  options: shiftOptions,
                  allLabel: l.allShiftsFilter,
                  onChanged: (v) => setState(() => _shiftFilter = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilterDropdown(
                  label: l.academicYearLabel,
                  value: _academicYearFilter,
                  options: academicYearOptions,
                  allLabel: l.allAcademicYearsFilter,
                  onChanged: (v) => setState(() => _academicYearFilter = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: l.searchCoursesHint,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],

        if (courses.isEmpty)
          EmptyState(
            icon: Icons.folder_open_outlined,
            title: l.noEnrolledCoursesTitle,
            subtitle: l.noEnrolledCoursesSubtitle,
          )
        else if (filtered.isEmpty)
          EmptyState(
            icon: Icons.search_off_rounded,
            title: l.noCoursesMatchFilters,
            subtitle: l.tryDifferentSearch,
          )
        else
          ...filtered.map(
            (course) => _CourseCard(
              subject: course,
              onTap: () => Navigator.of(context).push(
                fadeRoute(
                  CourseWorkspaceScreen(
                    classId: course.classId,
                    subjectId: course.id,
                    subjectName: course.name,
                    className: course.className,
                    subjectIcon: course.icon,
                    subjectColor: course.color,
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
      appBar: AppBar(title: Text(l.myCourseTitle), leading: const BackButton()),
      body: SafeArea(top: false, child: refreshableBody),
    );
  }
}

/// One enrolled class's clean card — mirrors the web app's course card
/// (subject code + shift badge, title, class group, teacher, academic year,
/// total/completed quizzes, % complete footer with a "View Quizzes" action).
class _CourseCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;
  const _CourseCard({required this.subject, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final total = subject.totalAssessments;
    final completed = subject.completed;
    final percent = total == 0 ? 0 : ((completed / total) * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: softCardDecoration(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
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
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            subject.code,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (subject.shift.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.14,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 11,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  subject.shift,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subject.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.groups_rounded,
                          size: 13,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            subject.className,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    if (subject.teacher.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 13,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l.teacherPrefixLabel(subject.teacher),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (subject.academicYear.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.academicYearLabel.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subject.academicYear,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _statBox(
                            label: l.totalQuizzesBoxLabel,
                            value: '$total',
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statBox(
                            label: l.completedChartLabel,
                            value: '$completed',
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l.percentCompleteLabel(percent),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(l.viewQuizzesAction),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        textStyle: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
