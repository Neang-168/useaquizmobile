import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'assessment_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Assessment assessment;
  const QuizScreen({super.key, required this.assessment});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final Assessment _assessment = widget.assessment;
  late final List<int?> _answers = List.filled(_assessment.questions.length, null);
  late final List<bool> _flagged = List.filled(_assessment.questions.length, false);
  int _current = 0;
  late Duration _remaining = Duration(minutes: _assessment.timeLimitMinutes);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining.inSeconds <= 0) {
        t.cancel();
        _goToResult();
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _answeredCount => _answers.where((a) => a != null).length;
  bool _submitting = false;

  Future<void> _goToResult() async {
    _timer?.cancel();
    if (_submitting) return;
    setState(() => _submitting = true);

    final timeSpent = Duration(minutes: _assessment.timeLimitMinutes) - _remaining;
    try {
      final result = await AppRepository.instance.submitAssessment(
        assessmentId: _assessment.id,
        answers: _answers,
        timeSpent: timeSpent,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(fadeRoute(AssessmentResultScreen(
        subjectName: _assessment.subject,
        result: result.data,
        isDemo: result.isDemo,
      )));
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Couldn\'t submit: $e'), backgroundColor: AppColors.danger));
    }
  }

  void _showSubmitDialog() {
    final unanswered = _assessment.questions.length - _answeredCount;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: (unanswered > 0 ? AppColors.warning : AppColors.secondary).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(unanswered > 0 ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                    color: unanswered > 0 ? AppColors.warning : AppColors.secondary, size: 30),
              ),
              const SizedBox(height: 16),
              Text('Submit Assessment?', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                unanswered > 0
                    ? 'You have $unanswered unanswered question${unanswered > 1 ? 's' : ''}. You can\'t change your answers after submitting.'
                    : 'You have answered all questions. You can\'t change your answers after submitting.',
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Continue Assessment'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _goToResult();
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _assessment.questions[_current];
    final progress = (_current + 1) / _assessment.questions.length;
    final lowTime = _remaining.inSeconds <= 60;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: close, progress, timer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: (lowTime ? AppColors.danger : AppColors.primary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 16, color: lowTime ? AppColors.danger : AppColors.primary),
                        const SizedBox(width: 5),
                        Text(_timeLabel,
                            style: TextStyle(
                                color: lowTime ? AppColors.danger : AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Question ${_current + 1} of ${_assessment.questions.length}',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => setState(() => _flagged[_current] = !_flagged[_current]),
                    child: Row(
                      children: [
                        Icon(_flagged[_current] ? Icons.flag_rounded : Icons.flag_outlined,
                            size: 18, color: _flagged[_current] ? AppColors.warning : AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(_flagged[_current] ? 'Flagged' : 'Flag',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: _flagged[_current] ? AppColors.warning : AppColors.textMuted,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: softCardDecoration(),
                    child: Text(q.text, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 19)),
                  ),
                  const SizedBox(height: 18),
                  ...List.generate(q.options.length, (i) {
                    final selected = _answers[_current] == i;
                    final letter = String.fromCharCode(65 + i);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        onTap: () => setState(() => _answers[_current] = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.6 : 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selected ? AppColors.primary : AppColors.background,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                                ),
                                child: Text(letter,
                                    style: TextStyle(
                                        color: selected ? Colors.white : AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                  child: Text(q.options[i],
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400))),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Bottom nav bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
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
                    child: _current == _assessment.questions.length - 1
                        ? ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                            onPressed: _submitting ? null : _showSubmitDialog,
                            icon: _submitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.check_rounded, size: 18),
                            label: Text(_submitting ? 'Submitting...' : 'Submit'),
                          )
                        : ElevatedButton.icon(
                            onPressed: () => setState(() => _current++),
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
