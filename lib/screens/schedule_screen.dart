import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../l10n/generated/app_localizations.dart';

/// Month calendar + a list of what's scheduled on the selected day. Shared
/// by both roles — [AppRepository.fetchSchedule] internally picks
/// `/teacher/calendar` or `/student/calendar` based on the logged-in role.
class ScheduleScreen extends StatefulWidget {
  final bool embedded;
  const ScheduleScreen({super.key, this.embedded = false});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _displayedMonth;
  late DateTime _selectedDay;
  late Future<List<ScheduleItem>> _future;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _future = _load();
  }

  Future<List<ScheduleItem>> _load() => AppRepository.instance.fetchSchedule(
    month: _displayedMonth.month,
    year: _displayedMonth.year,
  );

  void _retry() => setState(() => _future = _load());

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + delta,
        1,
      );
      _future = _load();
    });
  }

  void _selectDay(DateTime day) => setState(() => _selectedDay = day);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final futureBuilder = FutureBuilder<List<ScheduleItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Padding(
            padding: widget.embedded
                ? EdgeInsets.zero
                : const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: const Column(
              children: [
                SkeletonBox(height: 360, radius: 20),
                SizedBox(height: 24),
                SkeletonBox(height: 100, radius: 20),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return ErrorStateView(
            message: describeApiError(snapshot.error!),
            onRetry: _retry,
          );
        }
        final items = snapshot.data!;
        final content = [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: softCardDecoration(),
            child: _CalendarGrid(
              displayedMonth: _displayedMonth,
              selectedDay: _selectedDay,
              hasItemsOn: (day) => items.any((i) => i.coversDate(day)),
              onPrevMonth: () => _changeMonth(-1),
              onNextMonth: () => _changeMonth(1),
              onSelectDay: _selectDay,
            ),
          ),
          const SizedBox(height: 26),
          if (!widget.embedded) ...[
            SectionHeader(title: l.scheduleSectionTitle),
            const SizedBox(height: 12),
          ],
          ..._scheduleList(context, items),
        ];
        if (widget.embedded) return Column(children: content);
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: content,
        );
      },
    );

    if (widget.embedded) return futureBuilder;
    return Scaffold(
      appBar: AppBar(title: Text(l.scheduleAppBarTitle)),
      body: SafeArea(child: futureBuilder),
    );
  }

  List<Widget> _scheduleList(BuildContext context, List<ScheduleItem> items) {
    final l = AppLocalizations.of(context);
    final dayItems = items.where((i) => i.coversDate(_selectedDay)).toList();
    if (dayItems.isEmpty) {
      return [
        EmptyState(
          icon: Icons.event_busy_outlined,
          title: l.noDataTitle,
          subtitle: l.noDataSubtitle,
        ),
      ];
    }
    return dayItems
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: softCardDecoration(),
              child: Row(
                children: [
                  IconBadge(
                    icon: iconForSubjectCode(item.subjectCode),
                    color: colorForSeed(
                      item.subjectCode.isNotEmpty ? item.subjectCode : item.id,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.subjectName} · ${item.className}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (item.startAt != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatDisplayDate(item.startAt, withTime: true),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  StatusPill(
                    label: item.status,
                    color: item.status == 'Published'
                        ? AppColors.success
                        : AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime displayedMonth;
  final DateTime selectedDay;
  final bool Function(DateTime day) hasItemsOn;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDay;

  const _CalendarGrid({
    required this.displayedMonth,
    required this.selectedDay,
    required this.hasItemsOn,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onSelectDay,
  });

  static const _weekdayLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  static const _weekdayLabelsKm = ['អា', 'ច', 'អ', 'ព', 'ព្រ', 'សុ', 'ស'];
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _monthNamesKm = [
    'មករា',
    'កុម្ភៈ',
    'មីនា',
    'មេសា',
    'ឧសភា',
    'មិថុនា',
    'កក្កដា',
    'សីហា',
    'កញ្ញា',
    'តុលា',
    'វិច្ឆិកា',
    'ធ្នូ',
  ];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final isKhmer = Localizations.localeOf(context).languageCode == 'km';
    final weekdayLabels = isKhmer ? _weekdayLabelsKm : _weekdayLabels;
    final monthNames = isKhmer ? _monthNamesKm : _monthNames;
    final firstOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    ).day;
    final leading = firstOfMonth.weekday % 7; // Sunday-first grid
    final totalCells = ((leading + daysInMonth) / 7).ceil() * 7;
    final today = DateTime.now();
    final cells = List.generate(
      totalCells,
      (i) => firstOfMonth.add(Duration(days: i - leading)),
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              color: AppColors.primary,
              onPressed: onPrevMonth,
            ),
            Text(
              '${monthNames[displayedMonth.month - 1]} ${displayedMonth.year}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              color: AppColors.primary,
              onPressed: onNextMonth,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: weekdayLabels
              .map(
                (l) => Expanded(
                  child: Center(
                    child: Text(
                      l,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cells.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemBuilder: (context, i) {
            final day = cells[i];
            final inMonth = day.month == displayedMonth.month;
            final selected = _isSameDay(day, selectedDay);
            final marked = inMonth && hasItemsOn(day);
            final isToday = _isSameDay(day, today);

            Color? bg;
            Color textColor;
            var weight = FontWeight.w500;
            if (selected) {
              bg = AppColors.primary;
              textColor = Colors.white;
              weight = FontWeight.w700;
            } else if (marked) {
              bg = AppColors.primary.withValues(alpha: 0.08);
              textColor = AppColors.danger;
              weight = FontWeight.w700;
            } else if (!inMonth) {
              textColor = AppColors.textMuted.withValues(alpha: 0.5);
            } else {
              textColor = AppColors.textPrimary;
            }

            return Padding(
              padding: const EdgeInsets.all(3),
              child: GestureDetector(
                onTap: inMonth ? () => onSelectDay(day) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday && !selected
                        ? Border.all(color: AppColors.primary, width: 1.2)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: weight,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
