import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import '../l10n/generated/app_localizations.dart';
import 'assessment_instructions_screen.dart';

class AssessmentDetailsScreen extends StatefulWidget {
  final String assessmentId;
  const AssessmentDetailsScreen({super.key, this.assessmentId = 'assess-android-101'});

  @override
  State<AssessmentDetailsScreen> createState() => _AssessmentDetailsScreenState();
}

class _AssessmentDetailsScreenState extends State<AssessmentDetailsScreen> {
  late Future<Assessment> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.fetchAssessment(widget.assessmentId);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.assessmentDetailsTitle), leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: FutureBuilder<Assessment>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorStateView(
                message: describeApiError(snapshot.error!),
                onRetry: () => setState(() {
                  _future = AppRepository.instance.fetchAssessment(widget.assessmentId);
                }),
              );
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Column(children: [
                  SkeletonBox(height: 100, radius: 20),
                  SizedBox(height: 18),
                  SkeletonBox(height: 220, radius: 20),
                ]),
              );
            }
            final a = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
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
                                  Text(l.preStudyAssessmentLabel, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
                            _infoRow(context, Icons.meeting_room_outlined, l.classLabel, a.className),
                            const Divider(height: 24),
                            _infoRow(context, Icons.quiz_outlined, l.totalQuestionsLabel, l.totalQuestionsValue(a.totalQuestions)),
                            const Divider(height: 24),
                            _infoRow(context, Icons.timer_outlined, l.timeLimitLabel, l.minutesValue(a.duration)),
                            const Divider(height: 24),
                            _infoRow(context, Icons.military_tech_outlined, l.totalPointsPassMarkLabel,
                                l.pointsPassMarkValue(a.totalPoints, a.passMark)),
                            const Divider(height: 24),
                            _infoRow(context, Icons.replay_rounded, l.attemptsLabel, l.attemptsValue(a.attemptsUsed, a.maxAttempts)),
                            const Divider(height: 24),
                            _infoRow(context, Icons.event_available_outlined, l.availableFromLabel,
                                a.startAt == null ? l.anytimeLabel : formatDisplayDate(a.startAt, withTime: true)),
                            const Divider(height: 24),
                            _infoRow(context, Icons.event_busy_outlined, l.dueDateLabel,
                                a.endAt == null ? l.noDeadlineLabel : formatDisplayDate(a.endAt, withTime: true)),
                          ],
                        ),
                      ),
                      if (a.description.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(l.aboutThisQuiz, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: softCardDecoration(),
                          child: Text(a.description, style: Theme.of(context).textTheme.bodyLarge),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(l.instructionsTitle, style: Theme.of(context).textTheme.titleLarge),
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
                                l.honestyNotice,
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
                        ? l.attemptsUsedUp
                        : a.isClosed
                            ? l.assessmentClosed
                            : l.startAssessment),
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
