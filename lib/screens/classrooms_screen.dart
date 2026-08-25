import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'subjects_screen.dart';

class ClassRoomsScreen extends StatefulWidget {
  final bool embedded;
  final void Function(ClassRoom)? onClassRoomTap;
  const ClassRoomsScreen({super.key, this.embedded = false, this.onClassRoomTap});

  @override
  State<ClassRoomsScreen> createState() => _ClassRoomsScreenState();
}

class _ClassRoomsScreenState extends State<ClassRoomsScreen> {
  String _query = '';
  late Future<RepoResult<List<ClassRoom>>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchClassRooms();
  }

  Future<void> _refresh() async {
    final next = AppRepository.instance.fetchClassRooms();
    await next;
    if (mounted) setState(() => _future = next);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RepoResult<List<ClassRoom>>>(
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
            ],
          );
          return widget.embedded ? loading : Scaffold(body: SafeArea(child: loading));
        }
        return _buildBody(context, snapshot.data!);
      },
    );
  }

  Widget _buildBody(BuildContext context, RepoResult<List<ClassRoom>> result) {
    final filtered = result.data.where((c) => c.name.toLowerCase().contains(_query.toLowerCase())).toList();

    final body = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text('My Class Rooms', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Select a class room to view its subjects', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),
        if (result.isDemo) const DemoModeBanner(),
        const SizedBox(height: 4),

        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Search class rooms...',
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 18),

        if (filtered.isEmpty)
          const EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No class rooms found',
            subtitle: 'Try a different search term.',
          )
        else
          ...filtered.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: softCardDecoration(),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    onTap: () => widget.onClassRoomTap != null
                        ? widget.onClassRoomTap!(c)
                        : Navigator.of(context)
                            .push(fadeRoute(SubjectsScreen(classRoomId: c.id, classRoomName: c.name))),
                    child: Row(
                      children: [
                        IconBadge(icon: c.icon, color: c.color, size: 50),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text('${c.totalSubjects} subject${c.totalSubjects == 1 ? '' : 's'}', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              )),
      ],
    );

    final refreshableBody = RefreshIndicator(onRefresh: _refresh, color: AppColors.primary, child: body);

    if (widget.embedded) return refreshableBody;
    return Scaffold(body: SafeArea(child: refreshableBody));
  }
}
