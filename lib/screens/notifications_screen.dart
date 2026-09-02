import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import '../l10n/generated/app_localizations.dart';
import 'quizzes_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<AppNotification>> _future;

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

  /// Mirrors the web notification list: tapping an item marks it read and,
  /// for quiz-related types, opens the assessments list; feedback messages
  /// open right in a dialog since there's no separate feedback view here.
  Future<void> _onItemTap(AppNotification n) async {
    if (!n.isRead) {
      try {
        await AppRepository.instance.markNotificationRead(n.id);
        if (mounted) {
          setState(() => _future = AppRepository.instance.fetchNotifications());
        }
      } catch (_) {
        // best-effort; ignore failures marking read
      }
    }
    if (!mounted) return;
    if (n.type == 'feedback_received') {
      _showFeedbackDialog(n);
    } else if (n.type.startsWith('quiz_')) {
      Navigator.of(context).push(fadeRoute(const QuizzesScreen()));
    }
  }

  void _showFeedbackDialog(AppNotification n) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(n.title),
        content: Text(n.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.closeAction),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.notificationsTitle),
        leading: const BackButton(),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text(
              l.markAllRead,
              style: const TextStyle(color: AppColors.primary, fontSize: 12.5),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<AppNotification>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    SkeletonBox(height: 80, radius: 20),
                    SizedBox(height: 12),
                    SkeletonBox(height: 80, radius: 20),
                    SizedBox(height: 12),
                    SkeletonBox(height: 80, radius: 20),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return ErrorStateView(
                message: describeApiError(snapshot.error!),
                onRetry: () => setState(
                  () => _future = AppRepository.instance.fetchNotifications(),
                ),
              );
            }
            final notifications = snapshot.data!;
            if (notifications.isEmpty) {
              return EmptyState(
                icon: Icons.notifications_off_outlined,
                title: l.noNotifications,
                subtitle: l.noNotificationsSubtitle,
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                ...notifications.map(
                  (n) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: !n.isRead
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: !n.isRead
                            ? Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                              )
                            : null,
                        boxShadow: !n.isRead
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        onTap: () => _onItemTap(n),
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
                                      Expanded(
                                        child: Text(
                                          n.title,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                      ),
                                      if (!n.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(
                                            left: 6,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n.message,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    n.time,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textMuted,
                                          fontSize: 11.5,
                                        ),
                                  ),
                                ],
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
          },
        ),
      ),
    );
  }
}
