import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'assessment_instructions_screen.dart';

class AssessmentDetailsScreen extends StatefulWidget {
  final String assessmentId;
  const AssessmentDetailsScreen({super.key, this.assessmentId = 'assess-android-101'});

  @override
  State<AssessmentDetailsScreen> createState() => _AssessmentDetailsScreenState();
}

class _AssessmentDetailsScreenState extends State<AssessmentDetailsScreen> {
  late Future<RepoResult<Assessment>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchAssessment(widget.assessmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assessment Details'), leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: FutureBuilder<RepoResult<Assessment>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Couldn\'t load assessment',
                subtitle: '${snapshot.error}',
              );
            }
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Column(children: [
                  SkeletonBox(height: 100, radius: 20),
                  SizedBox(height: 18),
                  SkeletonBox(height: 220, radius: 20),
                ]),
              );
            }
            final result = snapshot.data!;
            final a = result.data;
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      if (result.isDemo) const DemoModeBanner(),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(AppRadius.lg)),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(AppRadius.sm)),
                              child: Icon(a.icon, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pre-Study Assessment', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(a.subject,
                                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: softCardDecoration(),
                        child: Column(
                          children: [
                            _infoRow(context, Icons.meeting_room_outlined, 'Class', a.className),
                            const Divider(height: 24),
                            _infoRow(context, Icons.quiz_outlined, 'Total Questions', '${a.totalQuestions} questions'),
                            const Divider(height: 24),
                            _infoRow(context, Icons.timer_outlined, 'Time Limit', '${a.duration} minutes'),
                            const Divider(height: 24),
                            _infoRow(context, Icons.military_tech_outlined, 'Total Points / Pass Mark', '${a.totalPoints} pts · ${a.passMark}%'),
                            const Divider(height: 24),
                            _infoRow(context, Icons.replay_rounded, 'Attempts', '${a.attemptsUsed}/${a.maxAttempts} used'),
                            const Divider(height: 24),
                            _infoRow(context, Icons.event_available_outlined, 'Available From',
                                a.startAt == null ? 'Anytime' : formatDisplayDate(a.startAt, withTime: true)),
                            const Divider(height: 24),
                            _infoRow(context, Icons.event_busy_outlined, 'Due Date',
                                a.endAt == null ? 'No deadline' : formatDisplayDate(a.endAt, withTime: true)),
                          ],
                        ),
                      ),
                      if (a.description.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text('About This Quiz', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: softCardDecoration(),
                          child: Text(a.description, style: Theme.of(context).textTheme.bodyLarge),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text('Instructions', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppRadius.lg)),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This assessment measures your prior knowledge. It will not affect your final grade — answer honestly.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: ElevatedButton(
                    onPressed: (a.attemptsExhausted || a.isClosed)
                        ? null
                        : () => Navigator.of(context).push(fadeRoute(AssessmentInstructionsScreen(assessment: a))),
                    child: Text(a.attemptsExhausted
                        ? 'Attempts Used Up'
                        : a.isClosed
                            ? 'Assessment Closed'
                            : 'Start Assessment'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
