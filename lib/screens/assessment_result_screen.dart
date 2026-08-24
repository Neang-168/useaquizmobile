import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'answer_review_screen.dart';
import 'home_screen.dart';

class AssessmentResultScreen extends StatelessWidget {
  final String subjectName;
  final SubmissionResult result;
  final bool isDemo;

  const AssessmentResultScreen({super.key, required this.subjectName, required this.result, this.isDemo = false});

  @override
  Widget build(BuildContext context) {
    final level = result.level;
    final pct = result.percentage.round();
    final canReview = (result.reviewQuestions?.isNotEmpty ?? false);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            if (isDemo) const DemoModeBanner(),
            Center(
              child: Column(
                children: [
                  Text('Assessment Complete', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(subjectName, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 28),
                  CircularPercentIndicator(
                    radius: 90,
                    lineWidth: 16,
                    percent: (pct / 100).clamp(0, 1),
                    backgroundColor: AppColors.border,
                    progressColor: level.color,
                    circularStrokeCap: CircularStrokeCap.round,
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$pct%', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 34)),
                        Text('Overall Score', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  StatusPill(label: level.label, color: level.color),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _statCard(context, Icons.stars_rounded, AppColors.primary, '${result.score}/${result.totalPoints}', 'Score'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(context, Icons.flag_circle_rounded, AppColors.secondary, '${result.passMark}%', 'Pass Mark'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                      context,
                      result.passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      result.passed ? AppColors.success : AppColors.danger,
                      result.passed ? 'Passed' : 'Not Passed',
                      'Status'),
                ),
              ],
            ),
            const SizedBox(height: 28),
            if (!canReview)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppRadius.lg)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('A per-question answer review isn\'t available yet — only your overall score is returned.',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(fadeRoute(AnswerReviewScreen(
                      questions: result.reviewQuestions!,
                      selections: result.reviewSelections ?? const [],
                    ))),
                icon: const Icon(Icons.rate_review_outlined, size: 19),
                label: const Text('View Review'),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(fadeRoute(const HomeScreen()), (r) => false),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, IconData icon, Color color, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: softCardDecoration(),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
