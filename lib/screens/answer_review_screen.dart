import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class AnswerReviewScreen extends StatefulWidget {
  final List<int?> answers;
  final List<Question> questions;
  final String title;
  const AnswerReviewScreen({super.key, required this.answers, required this.questions, this.title = 'Answer Review'});

  @override
  State<AnswerReviewScreen> createState() => _AnswerReviewScreenState();
}

class _AnswerReviewScreenState extends State<AnswerReviewScreen> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[_current];
    final studentAnswer = widget.answers[_current];
    final isCorrect = studentAnswer == q.correctIndex;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Question ${_current + 1} of ${widget.questions.length}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      StatusPill(
                        label: isCorrect ? 'Correct' : (studentAnswer == null ? 'Unanswered' : 'Incorrect'),
                        color: isCorrect ? AppColors.secondary : (studentAnswer == null ? AppColors.textMuted : AppColors.danger),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: softCardDecoration(),
                    child: Text(q.text, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(q.options.length, (i) {
                    final isCorrectOption = i == q.correctIndex;
                    final isStudentPick = i == studentAnswer;
                    Color borderColor = AppColors.border;
                    Color bg = Colors.white;
                    IconData? trailingIcon;
                    Color? iconColor;

                    if (isCorrectOption) {
                      borderColor = AppColors.secondary;
                      bg = AppColors.secondary.withValues(alpha: 0.08);
                      trailingIcon = Icons.check_circle_rounded;
                      iconColor = AppColors.secondary;
                    } else if (isStudentPick && !isCorrectOption) {
                      borderColor = AppColors.danger;
                      bg = AppColors.danger.withValues(alpha: 0.08);
                      trailingIcon = Icons.cancel_rounded;
                      iconColor = AppColors.danger;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: borderColor, width: 1.4),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(q.options[i], style: Theme.of(context).textTheme.bodyLarge)),
                            if (trailingIcon != null) Icon(trailingIcon, color: iconColor, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Text('Explanation', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppRadius.lg)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(child: Text(q.explanation, style: Theme.of(context).textTheme.bodyLarge)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, -4))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _current == 0 ? null : () => setState(() => _current--),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _current == widget.questions.length - 1 ? null : () => setState(() => _current++),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
