import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import 'assessment_result_screen.dart';

/// Loads the quiz's actual questions. Laravel's `GET /student/quizzes/{id}`
/// both fetches questions AND starts the timed attempt server-side, so this
/// call only happens once the user is actually on this screen (not earlier,
/// while merely viewing assessment details/instructions).
class QuizScreen extends StatefulWidget {
  final Assessment assessment;
  const QuizScreen({super.key, required this.assessment});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<Assessment> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.instance.startAssessment(widget.assessment.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<Assessment>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorStateView(
                message: describeApiError(snapshot.error!),
                onRetry: () => setState(() {
                  _future = AppRepository.instance.startAssessment(widget.assessment.id);
                }),
              );
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SkeletonBox(height: 60, radius: 16),
                    SizedBox(height: 18),
                    SkeletonBox(height: 220, radius: 20),
                  ],
                ),
              );
            }
            final assessment = snapshot.data!;
            if (assessment.questions.isEmpty) {
              return const EmptyState(
                icon: Icons.quiz_outlined,
                title: 'No questions available',
                subtitle: 'This quiz has no questions to take right now.',
              );
            }
            return _QuizTakingView(assessment: assessment);
          },
        ),
      ),
    );
  }
}

/// Mutable per-question answer state while taking the quiz — one instance
/// per question, shaped by that question's type.
class _AnswerState {
  String? selectedOptionId; // true_false / single-select multiple_choice
  final Set<String> selectedOptionIds = {}; // multi-select multiple_choice
  final Map<String, String?> matches =
      {}; // matching: leftPairId -> selectedRightPairId
}

class _QuizTakingView extends StatefulWidget {
  final Assessment assessment;
  const _QuizTakingView({required this.assessment});

  @override
  State<_QuizTakingView> createState() => _QuizTakingViewState();
}

class _QuizTakingViewState extends State<_QuizTakingView>
    with WidgetsBindingObserver {
  late final Assessment _assessment = widget.assessment;
  late final List<_AnswerState> _answers = List.generate(
    _assessment.questions.length,
    (i) {
      final state = _AnswerState();
      final q = _assessment.questions[i];
      if (q.isMatching) {
        for (final item in q.leftItems) {
          state.matches[item.pairId] = null;
        }
      }
      return state;
    },
  );
  late final List<bool> _flagged = List.filled(
    _assessment.questions.length,
    false,
  );
  int _current = 0;
  late Duration _remaining = _initialRemaining();
  Timer? _timer;
  int _tabSwitchCount = 0;
  bool _submitting = false;

  /// How far the device's clock is from the server's, measured once at
  /// start time (server_now - device_now). A phone with a fast/slow clock
  /// (or one deliberately tampered with to fool the timer) would otherwise
  /// throw off the countdown, since it's anchored to a server-issued
  /// deadline rather than a duration counted locally.
  Duration _clockSkew() {
    final serverNow = DateTime.tryParse(_assessment.serverNow ?? '');
    if (serverNow == null) return Duration.zero;
    return serverNow.difference(DateTime.now());
  }

  Duration _initialRemaining() {
    final deadline = _assessment.deadlineAt;
    if (deadline != null) {
      final dt = DateTime.tryParse(deadline);
      if (dt != null) {
        final d = dt.difference(DateTime.now().add(_clockSkew()));
        return d.isNegative ? Duration.zero : d;
      }
    }
    return Duration(minutes: _assessment.duration);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Backend tracks tab/app switches as a light academic-integrity signal.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _tabSwitchCount++;
    }
  }

  String get _timeLabel {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool _isAnswered(int i) {
    final q = _assessment.questions[i];
    final a = _answers[i];
    if (q.isMatching) {
      return a.matches.isNotEmpty && a.matches.values.every((v) => v != null);
    }
    if (q.multiSelect) return a.selectedOptionIds.isNotEmpty;
    return a.selectedOptionId != null;
  }

  int get _answeredCount => List.generate(
    _assessment.questions.length,
    _isAnswered,
  ).where((a) => a).length;

  Future<void> _goToResult() async {
    _timer?.cancel();
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final answers = <StudentAnswer>[];
      for (var i = 0; i < _assessment.questions.length; i++) {
        final q = _assessment.questions[i];
        final a = _answers[i];
        if (q.isMatching) {
          answers.add(
            StudentAnswer(
              questionId: q.id,
              matches: a.matches.entries
                  .map(
                    (e) => MatchAnswer(
                      leftPairId: e.key,
                      selectedRightPairId: e.value,
                    ),
                  )
                  .toList(),
            ),
          );
        } else if (q.multiSelect) {
          answers.add(
            StudentAnswer(
              questionId: q.id,
              selectedOptionIds: a.selectedOptionIds.toList(),
            ),
          );
        } else {
          answers.add(
            StudentAnswer(
              questionId: q.id,
              selectedOptionId: a.selectedOptionId,
            ),
          );
        }
      }

      final result = await AppRepository.instance.submitAssessment(
        assessmentId: _assessment.id,
        answers: answers,
        tabSwitchCount: _tabSwitchCount,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        fadeRoute(
          AssessmentResultScreen(
            subjectName: _assessment.subject,
            result: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Couldn\'t submit: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showSubmitDialog() {
    final unanswered = _assessment.questions.length - _answeredCount;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      (unanswered > 0 ? AppColors.warning : AppColors.success)
                          .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  unanswered > 0
                      ? Icons.error_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  color: unanswered > 0 ? AppColors.warning : AppColors.success,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Submit Assessment?',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
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

  /// Leaving mid-quiz does NOT stop the server-side timer — the attempt
  /// keeps running so it can't be used to reset the clock, then silently
  /// resumes with less time left next time. Warn before letting that happen,
  /// matching the web app's navigation lock during an active attempt.
  Future<bool> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave this assessment?'),
        content: const Text(
          'Your timer keeps running even after you leave. If it runs out before you come back, your answers so far will be submitted automatically.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Leave Anyway',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final q = _assessment.questions[_current];
    final progress = (_current + 1) / _assessment.questions.length;
    final lowTime = _remaining.inSeconds <= 60;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmExit();
        if (leave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Column(
        children: [
          // Top bar: close, progress, timer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    final leave = await _confirmExit();
                    if (leave && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
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
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: (lowTime ? AppColors.danger : AppColors.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: lowTime ? AppColors.danger : AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _timeLabel,
                        style: TextStyle(
                          color: lowTime ? AppColors.danger : AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
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
                Text(
                  'Question ${_current + 1} of ${_assessment.questions.length}',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _flagged[_current] = !_flagged[_current]),
                  child: Row(
                    children: [
                      Icon(
                        _flagged[_current]
                            ? Icons.flag_rounded
                            : Icons.flag_outlined,
                        size: 18,
                        color: _flagged[_current]
                            ? AppColors.warning
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _flagged[_current] ? 'Flagged' : 'Flag',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: _flagged[_current]
                              ? AppColors.warning
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.title,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(fontSize: 19),
                      ),
                      if (q.imageUrl != null) ...[
                        const SizedBox(height: 16),
                        _zoomableImage(q.imageUrl!, height: 180),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _buildQuestionBody(context, q),
              ],
            ),
          ),

          // Bottom nav bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _current == 0
                        ? null
                        : () => setState(() => _current--),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _current == _assessment.questions.length - 1
                      ? ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                          onPressed: _submitting ? null : _showSubmitDialog,
                          icon: _submitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_rounded, size: 18),
                          label: Text(_submitting ? 'Submitting...' : 'Submit'),
                        )
                      : ElevatedButton.icon(
                          onPressed: () => setState(() => _current++),
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                          label: const Text('Next'),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBody(BuildContext context, Question q) {
    if (q.isMatching) return _matchingBody(context, q);
    if (q.multiSelect) return _multiSelectBody(context, q);
    return _singleSelectBody(context, q);
  }

  Widget _singleSelectBody(BuildContext context, Question q) {
    final answer = _answers[_current];
    return Column(
      children: List.generate(q.options.length, (i) {
        final opt = q.options[i];
        final selected = answer.selectedOptionId == opt.id;
        final letter = String.fromCharCode(65 + i);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: () => setState(() => answer.selectedOptionId = opt.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 1.6 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      letter,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      opt.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (opt.imageUrl != null) ...[
                    const SizedBox(width: 12),
                    _optionThumbnail(opt.imageUrl!),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _multiSelectBody(BuildContext context, Question q) {
    final answer = _answers[_current];
    return Column(
      children: q.options.map((opt) {
        final selected = answer.selectedOptionIds.contains(opt.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: () => setState(() {
              if (selected) {
                answer.selectedOptionIds.remove(opt.id);
              } else {
                answer.selectedOptionIds.add(opt.id);
              }
            }),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 1.6 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: selected ? AppColors.primary : AppColors.textMuted,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      opt.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (opt.imageUrl != null) ...[
                    const SizedBox(width: 12),
                    _optionThumbnail(opt.imageUrl!),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _matchingBody(BuildContext context, Question q) {
    final answer = _answers[_current];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: q.leftItems.map((left) {
        final selectedRight = answer.matches[left.pairId];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: softCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        left.text,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (left.imageUrl != null) ...[
                      const SizedBox(width: 10),
                      _optionThumbnail(left.imageUrl!),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: q.rightItems.map((right) {
                    final selected = selectedRight == right.pairId;
                    return ChoiceChip(
                      avatar: right.imageUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(right.imageUrl!),
                            )
                          : null,
                      label: Text(right.text),
                      selected: selected,
                      onSelected: (_) => setState(
                        () => answer.matches[left.pairId] = right.pairId,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.background,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        side: BorderSide(color: AppColors.border),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Full-width, tap-to-zoom image for a question stem.
  Widget _zoomableImage(String url, {required double height}) {
    return GestureDetector(
      onTap: () => _openImageViewer(url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Image.network(
          url,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: height,
            color: AppColors.background,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  /// Small tap-to-zoom thumbnail for an option/matching-pair item.
  Widget _optionThumbnail(String url) {
    return GestureDetector(
      onTap: () => _openImageViewer(url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Image.network(
          url,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 56,
            height: 56,
            color: AppColors.background,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  void _openImageViewer(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Image.network(
                      url,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
