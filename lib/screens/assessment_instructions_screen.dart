import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'quiz_screen.dart';

class AssessmentInstructionsScreen extends StatelessWidget {
  final Assessment assessment;
  const AssessmentInstructionsScreen({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    final a = assessment;
    final rules = [
      (icon: Icons.timer_outlined, text: 'You have ${a.timeLimitMinutes} minutes to complete ${a.totalQuestions} questions.'),
      (icon: Icons.pause_circle_outline_rounded, text: 'The timer cannot be paused once the assessment starts.'),
      (icon: Icons.flag_outlined, text: 'You may flag questions and revisit them before submitting.'),
      (icon: Icons.check_circle_outline_rounded, text: 'A passing score is not required — this is a diagnostic quiz.'),
      (icon: Icons.shield_outlined, text: 'Answer independently. This assessment is covered by the academic honesty policy.'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Instructions'), leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    width: double.infinity,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppRadius.lg)),
                    child: Column(
                      children: [
                        const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 40),
                        const SizedBox(height: 10),
                        Text(a.subject, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text('Read the instructions carefully before you begin', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text('Before you start', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...rules.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: softCardDecoration(),
                          child: Row(
                            children: [
                              IconBadge(icon: r.icon, color: AppColors.primary, size: 40),
                              const SizedBox(width: 12),
                              Expanded(child: Text(r.text, style: Theme.of(context).textTheme.bodyLarge)),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.lg)),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'By starting, you confirm this work is entirely your own, in line with the university\'s Academic Honesty Policy.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF92400E)),
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
                onPressed: () => Navigator.of(context).push(fadeRoute(QuizScreen(assessment: a))),
                child: const Text('I Understand, Start Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
