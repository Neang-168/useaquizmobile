import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<RepoResult<List<AppNotification>>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchNotifications();
  }

  Future<void> _markAllRead() async {
    try {
      await AppRepository.instance.markAllNotificationsRead();
      setState(() => _future = AppRepository.instance.fetchNotifications());
    } catch (_) {
      // best-effort; ignore failures marking read
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: const BackButton(),
        actions: [
          TextButton(onPressed: _markAllRead, child: const Text('Mark all read', style: TextStyle(color: AppColors.primary, fontSize: 12.5))),
        ],
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<RepoResult<List<AppNotification>>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(children: [
                  SkeletonBox(height: 80, radius: 20),
                  SizedBox(height: 12),
                  SkeletonBox(height: 80, radius: 20),
                  SizedBox(height: 12),
                  SkeletonBox(height: 80, radius: 20),
                ]),
              );
            }
            final result = snapshot.data!;
            final notifications = result.data;
            if (notifications.isEmpty) {
              return const EmptyState(
                  icon: Icons.notifications_off_outlined, title: 'No notifications', subtitle: 'You\'re all caught up!');
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (result.isDemo) const DemoModeBanner(),
                ...notifications.map((n) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: n.unread ? AppColors.primary.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: n.unread ? Border.all(color: AppColors.primary.withOpacity(0.2)) : null,
                          boxShadow: n.unread
                              ? null
                              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 6))],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconBadge(icon: n.icon, color: n.color, size: 44),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(n.title, style: Theme.of(context).textTheme.titleMedium)),
                                      if (n.unread)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(left: 6),
                                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(n.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(height: 6),
                                  Text(n.time,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted, fontSize: 11.5)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}
