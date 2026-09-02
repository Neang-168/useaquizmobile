import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import '../l10n/generated/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  final bool embedded;
  const HistoryScreen({super.key, this.embedded = false});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _query = '';
  // null means "All" for both.
  String? _subjectFilter;
  bool? _passedFilter;
  late Future<List<HistoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchHistory();
  }

  void _retry() =>
      setState(() => _future = AppRepository.instance.fetchHistory());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoryItem>>(
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
            appBar: AppBar(
              title: Text(AppLocalizations.of(context).historyAppBarTitle),
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
              title: Text(AppLocalizations.of(context).historyAppBarTitle),
              leading: const BackButton(),
            ),
            body: SafeArea(top: false, child: error),
          );
        }
        return _buildBody(context, snapshot.data!);
      },
    );
  }

  Widget _buildBody(BuildContext context, List<HistoryItem> history) {
    final l = AppLocalizations.of(context);
    final subjectOptions =
        history
            .map((h) => h.subject)
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final filtered = history.where((h) {
      final q = _query.toLowerCase();
      final matchesQuery =
          h.subject.toLowerCase().contains(q) ||
          h.quizTitle.toLowerCase().contains(q);
      final matchesSubject =
          _subjectFilter == null || h.subject == _subjectFilter;
      final matchesStatus = _passedFilter == null || h.passed == _passedFilter;
      return matchesQuery && matchesSubject && matchesStatus;
    }).toList();

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          l.assessmentHistoryTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          l.trackHistorySubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: l.searchBySubjectHint,
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 12),
        FilterDropdown(
          label: l.filterSubjectLabel,
          value: _subjectFilter,
          options: subjectOptions,
          allLabel: l.allSubjectsFilter,
          onChanged: (v) => setState(() => _subjectFilter = v),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [null, true, false].map((f) {
              final selected = _passedFilter == f;
              final label = f == null
                  ? l.allFilter
                  : (f ? l.passed : l.notPassed);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setState(() => _passedFilter = f),
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
            icon: Icons.history_toggle_off_rounded,
            title: l.noHistoryFound,
            subtitle: l.noHistoryFoundSubtitle,
          )
        else
          ...filtered.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: softCardDecoration(),
                child: Row(
                  children: [
                    IconBadge(
                      icon: Icons.description_rounded,
                      color: h.color,
                      size: 48,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.quizTitle.isNotEmpty ? h.quizTitle : h.subject,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            h.subject,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatDisplayDate(h.submittedAt),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${h.percentage.round()}%',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        StatusPill(
                          label: h.passed ? l.passed : l.notPassed,
                          color: h.passed
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.historyAppBarTitle),
        leading: const BackButton(),
      ),
      body: SafeArea(top: false, child: body),
    );
  }
}
