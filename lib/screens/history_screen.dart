import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';

class HistoryScreen extends StatefulWidget {
  final bool embedded;
  const HistoryScreen({super.key, this.embedded = false});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _query = '';
  String _filter = 'All';
  late Future<RepoResult<List<HistoryItem>>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RepoResult<List<HistoryItem>>>(
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

  Widget _buildBody(BuildContext context, RepoResult<List<HistoryItem>> result) {
    final filtered = result.data.where((h) {
      final q = _query.toLowerCase();
      final matchesQuery = h.subject.toLowerCase().contains(q) || h.quizTitle.toLowerCase().contains(q);
      final matchesFilter = _filter == 'All' || h.level.label == _filter;
      return matchesQuery && matchesFilter;
    }).toList();

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text('Assessment History', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Track all your completed pre-study assessments', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),
        if (result.isDemo) const DemoModeBanner(),
        const SizedBox(height: 4),
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Search by subject...',
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
          const EmptyState(
            icon: Icons.history_toggle_off_rounded,
            title: 'No history found',
            subtitle: 'Completed assessments will show up here.',
          )
        else
          ...filtered.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: softCardDecoration(),
                  child: Row(
                    children: [
                      IconBadge(icon: Icons.description_rounded, color: h.color, size: 48),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.quizTitle.isNotEmpty ? h.quizTitle : h.subject, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(h.subject, style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 4),
                            Row(children: [
                              Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(formatDisplayDate(h.submittedAt), style: Theme.of(context).textTheme.bodyMedium),
                            ]),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${h.percentage.round()}%', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          StatusPill(label: h.level.label, color: h.color),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(body: SafeArea(child: body));
  }
}
