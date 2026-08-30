import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

/// Per-question right/wrong breakdown for a subject's quizzes. The live
/// `/teacher/quizzes/{id}/scores` endpoint only returns aggregate mcq/essay
/// scores per submission — no per-question answer detail exists anywhere in
/// the API for a teacher to fetch — so this view can't be built from real
/// data and always shows the "unavailable" state below.
class ClassQuestionBreakdownScreen extends StatelessWidget {
  final String subjectId;
  final String subjectName;
  const ClassQuestionBreakdownScreen({super.key, required this.subjectId, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subjectName), leading: const BackButton()),
      body: const SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: EmptyState(
            icon: Icons.info_outline_rounded,
            title: 'Per-question breakdown unavailable',
            subtitle:
                'The API only returns each student\'s overall score, not their answer to every question, so this view can\'t be built from live data.',
          ),
        ),
      ),
    );
  }
}
