import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/generated/app_localizations.dart';

/// Model-layer code has no [BuildContext] to call `AppLocalizations.of`, so
/// it looks the current translation up directly from [LocaleController]'s
/// locale instead — same live-updating source the widget tree itself reads.
AppLocalizations get _l => lookupAppLocalizations(LocaleController.locale.value);

/// The live API never sends icon/color strings for any entity — these are
/// derived client-side from stable identifiers (subject code, notification
/// type, score percentage) instead.
const List<Color> _palette = [
  Color(0xFF2563EB), // blue
  Color(0xFFF59E0B), // amber
  Color(0xFF7C3AED), // purple
  Color(0xFFEF4444), // red
  Color(0xFF10B981), // green
  Color(0xFF3B82F6), // light blue
];

Color colorForSeed(String seed) {
  if (seed.isEmpty) return _palette[0];
  final hash = seed.codeUnits.fold<int>(0, (a, c) => a + c);
  return _palette[hash % _palette.length];
}

IconData iconForSubjectCode(String? code) {
  final c = (code ?? '').toLowerCase();
  if (c.contains('web')) return Icons.language_rounded;
  if (c.contains('db') || c.contains('data')) return Icons.storage_rounded;
  if (c.contains('net') || c.contains('sec')) return Icons.hub_rounded;
  if (c.contains('mob') || c.contains('and') || c.contains('ios')) {
    return Icons.phone_android_rounded;
  }
  if (c.contains('se') || c.contains('sw')) {
    return Icons.integration_instructions_rounded;
  }
  return Icons.school_rounded;
}

IconData iconForNotificationType(String? type) => switch (type) {
  'quiz_published' => Icons.assignment_rounded,
  'quiz_starting_soon' => Icons.play_circle_outline_rounded,
  'quiz_ending_soon' || 'quiz_closing_soon' => Icons.alarm_rounded,
  'feedback_received' => Icons.campaign_rounded,
  _ => Icons.notifications_rounded,
};

Color colorForNotificationType(String? type) => switch (type) {
  'quiz_published' => AppColors.primary,
  'quiz_starting_soon' => AppColors.secondary,
  'quiz_ending_soon' || 'quiz_closing_soon' => AppColors.warning,
  'feedback_received' => const Color(0xFF7C3AED),
  _ => AppColors.primary,
};

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const _monthsKm = [
  'មករា',
  'កុម្ភៈ',
  'មីនា',
  'មេសា',
  'ឧសភា',
  'មិថុនា',
  'កក្កដា',
  'សីហា',
  'កញ្ញា',
  'តុលា',
  'វិច្ឆិកា',
  'ធ្នូ',
];

/// Formats an ISO-ish date string (as returned by Laravel, e.g.
/// `2026-07-21T09:00` or `2026-07-21T09:00:00`) into a human date, matching
/// the display style the UI already used for its literal mock dates.
String formatDisplayDate(String? iso, {bool withTime = false}) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  final months = LocaleController.locale.value.languageCode == 'km' ? _monthsKm : _months;
  final date = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  if (!withTime) return date;
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  return '$date, $h:$m $ampm';
}

/// Formats a timestamp as a short relative time ("2h ago"), the way the
/// notification list used to display its literal mock `time` field.
String formatRelativeTime(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  final diff = DateTime.now().difference(dt);
  final l = _l;
  if (diff.inMinutes < 1) return l.justNow;
  if (diff.inMinutes < 60) return l.minutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l.hoursAgo(diff.inHours);
  if (diff.inDays < 2) return l.yesterday;
  if (diff.inDays < 7) return l.daysAgo(diff.inDays);
  return formatDisplayDate(iso);
}

enum PerformanceLevel { excellent, good, average, beginner }

extension PerformanceLevelX on PerformanceLevel {
  String get label => switch (this) {
    PerformanceLevel.excellent => _l.excellentLevel,
    PerformanceLevel.good => _l.goodLevel,
    PerformanceLevel.average => _l.averageLevel,
    PerformanceLevel.beginner => _l.beginnerLevel,
  };

  Color get color => switch (this) {
    PerformanceLevel.excellent => const Color(0xFF10B981),
    PerformanceLevel.good => const Color(0xFF3B82F6),
    PerformanceLevel.average => const Color(0xFFF59E0B),
    PerformanceLevel.beginner => const Color(0xFFEF4444),
  };
}

/// The live API only ever returns a score/percentage, never a pre-labelled
/// performance tier — every screen that used to read a server-sent `status`
/// string (e.g. "Excellent") now derives it from the percentage instead.
PerformanceLevel levelForPercent(num pct) => pct >= 90
    ? PerformanceLevel.excellent
    : pct >= 70
    ? PerformanceLevel.good
    : pct >= 50
    ? PerformanceLevel.average
    : PerformanceLevel.beginner;

/// A subject/course, as seen from either role. Source shape differs (see
/// the two named factories) since Laravel has no single generic "subjects"
/// endpoint — students get it from their course enrollments, teachers from
/// their subject assignments.
class Subject {
  final String id;
  final String
  classId; // student-only; empty when sourced from a teacher assignment
  final String name;
  final String code;
  final String className; // enrolled/assigned class name(s)
  final String teacher; // student-only
  final IconData icon;
  final Color color;
  final int totalAssessments;
  final int completed;

  const Subject({
    this.id = '',
    this.classId = '',
    required this.name,
    required this.code,
    this.className = '',
    this.teacher = '',
    required this.icon,
    required this.color,
    this.totalAssessments = 0,
    this.completed = 0,
  });

  factory Subject.fromStudentCourseJson(Map<String, dynamic> j) => Subject(
    id: '${j['id']}',
    classId: '${j['classId'] ?? ''}',
    name: j['title'] ?? '',
    code: j['code'] ?? '',
    className: j['className'] ?? '',
    teacher: j['teacher'] ?? '',
    icon: iconForSubjectCode(j['code']),
    color: colorForSeed('${j['code'] ?? j['id']}'),
    totalAssessments: j['totalQuizzes'] ?? 0,
    completed: j['completedQuizzes'] ?? 0,
  );

  factory Subject.fromTeacherSubjectJson(Map<String, dynamic> j) => Subject(
    id: '${j['id']}',
    name: j['name'] ?? '',
    code: j['code'] ?? '',
    className: (j['assignedClasses'] as List? ?? const []).join(', '),
    icon: iconForSubjectCode(j['code']),
    color: colorForSeed('${j['code'] ?? j['id']}'),
  );
}

/// A class room a student/teacher belongs to. Laravel has no dedicated
/// "classrooms" endpoint — this is built by the repository from whichever
/// course/class list it already fetched, deduped by class id.
class ClassRoom {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int totalSubjects;

  const ClassRoom({
    this.id = '',
    required this.name,
    required this.icon,
    required this.color,
    required this.totalSubjects,
  });
}

/// One selectable option for a multiple_choice or true_false question.
class QuestionOption {
  final String id;
  final String text;
  final String? imageUrl;

  /// Demo-only: whether this is a correct option. The live API strips
  /// correctness entirely when a student is taking a quiz, so this is only
  /// ever populated by [mock_data.dart]'s hand-built demo questions — never
  /// set by [QuestionOption.fromJson].
  final bool isCorrect;

  const QuestionOption({
    required this.id,
    required this.text,
    this.imageUrl,
    this.isCorrect = false,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> j) => QuestionOption(
    id: '${j['id']}',
    text: j['text'] ?? '',
    imageUrl: j['imageUrl'],
  );
}

/// One side of a matching-pair row. The same `pairId` appears on both the
/// left and right item of a correct pair.
class MatchPairItem {
  final String pairId;
  final String text;
  final String? imageUrl;

  const MatchPairItem({
    required this.pairId,
    required this.text,
    this.imageUrl,
  });

  factory MatchPairItem.fromJson(Map<String, dynamic> j) => MatchPairItem(
    pairId: '${j['pairId']}',
    text: j['text'] ?? '',
    imageUrl: j['imageUrl'],
  );
}

/// A quiz question. Three shapes share one class (matching the API's own
/// polymorphic `type` field) rather than three subclasses, since the taking
/// UI already has to branch on `type` at render time regardless.
class Question {
  final String id;
  final String type; // 'multiple_choice' | 'true_false' | 'matching'
  final int points;
  final bool multiSelect; // multiple_choice only
  final String title;
  final String? imageUrl;
  final String? imageAlt;
  final List<QuestionOption> options; // multiple_choice / true_false
  final List<MatchPairItem> leftItems; // matching
  final List<MatchPairItem> rightItems; // matching

  const Question({
    this.id = '',
    required this.type,
    this.points = 1,
    this.multiSelect = false,
    required this.title,
    this.imageUrl,
    this.imageAlt,
    this.options = const [],
    this.leftItems = const [],
    this.rightItems = const [],
  });

  bool get isMultipleChoice => type == 'multiple_choice';
  bool get isTrueFalse => type == 'true_false';
  bool get isMatching => type == 'matching';

  factory Question.fromJson(Map<String, dynamic> j) => Question(
    id: '${j['id']}',
    type: j['type'] ?? 'multiple_choice',
    points: j['points'] ?? 1,
    multiSelect: j['multiSelect'] ?? false,
    title: j['title'] ?? '',
    imageUrl: j['imageUrl'],
    imageAlt: j['imageAlt'],
    options: (j['options'] as List? ?? const [])
        .map((o) => QuestionOption.fromJson(Map<String, dynamic>.from(o)))
        .toList(),
    leftItems: (j['leftItems'] as List? ?? const [])
        .map((p) => MatchPairItem.fromJson(Map<String, dynamic>.from(p)))
        .toList(),
    rightItems: (j['rightItems'] as List? ?? const [])
        .map((p) => MatchPairItem.fromJson(Map<String, dynamic>.from(p)))
        .toList(),
  );
}

/// One matched pair in a student's answer to a matching question.
class MatchAnswer {
  final String leftPairId;
  final String? selectedRightPairId;

  const MatchAnswer({required this.leftPairId, this.selectedRightPairId});

  Map<String, dynamic> toJson() => {
    'leftPairId': int.tryParse(leftPairId) ?? leftPairId,
    'selectedRightPairId': selectedRightPairId == null
        ? null
        : (int.tryParse(selectedRightPairId!) ?? selectedRightPairId),
  };
}

/// A student's answer to one question, shaped to match whichever fields
/// `POST /student/quizzes/{id}/submit` expects for that question's type.
class StudentAnswer {
  final String questionId;
  final String?
  selectedOptionId; // true_false, or multiple_choice single-select
  final List<String> selectedOptionIds; // multiple_choice multi-select
  final List<MatchAnswer> matches; // matching

  const StudentAnswer({
    required this.questionId,
    this.selectedOptionId,
    this.selectedOptionIds = const [],
    this.matches = const [],
  });

  Map<String, dynamic> toJson() => {
    'questionId': int.tryParse(questionId) ?? questionId,
    if (selectedOptionId != null)
      'selectedOptionId': int.tryParse(selectedOptionId!) ?? selectedOptionId,
    if (selectedOptionIds.isNotEmpty)
      'selectedOptionIds': selectedOptionIds
          .map((id) => int.tryParse(id) ?? id)
          .toList(),
    if (matches.isNotEmpty) 'matches': matches.map((m) => m.toJson()).toList(),
  };
}

/// A quiz, as returned by the student/teacher quiz-list and quiz-detail
/// endpoints. [questions] is only populated by the single-quiz "for taking"
/// response (`GET /student/quizzes/{id}`); list responses leave it empty.
class Assessment {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String classId;
  final String subject;
  final String subjectCode;
  final String className;
  final int duration; // minutes
  final int maxAttempts;
  final int attemptsUsed;
  final int passMark;
  final int? totalScore;
  final String? startAt;
  final String? endAt;
  final int totalQuestions;
  final int totalPoints;
  final String status;
  final bool isUpcoming;
  final bool isOpen;
  final bool isClosed;
  final bool attemptsExhausted;
  final int? bestScore;
  final double? bestPercentage;
  final String? lastSubmittedAt;

  // Populated only by the detail/"for taking" response:
  final int? attemptNumber;
  final String? deadlineAt;
  final String? serverNow; // server's clock at start time, for skew correction
  final List<Question> questions;

  final IconData icon;
  final Color color;

  const Assessment({
    this.id = '',
    this.title = '',
    this.description = '',
    this.subjectId = '',
    this.classId = '',
    required this.subject,
    this.subjectCode = '',
    this.className = '',
    this.duration = 15,
    this.maxAttempts = 1,
    this.attemptsUsed = 0,
    this.passMark = 50,
    this.totalScore,
    this.startAt,
    this.endAt,
    this.totalQuestions = 0,
    this.totalPoints = 0,
    this.status = 'not_started',
    this.isUpcoming = false,
    this.isOpen = true,
    this.isClosed = false,
    this.attemptsExhausted = false,
    this.bestScore,
    this.bestPercentage,
    this.lastSubmittedAt,
    this.attemptNumber,
    this.deadlineAt,
    this.serverNow,
    this.questions = const [],
    required this.icon,
    required this.color,
  });

  factory Assessment.fromJson(Map<String, dynamic> j) => Assessment(
    id: '${j['id']}',
    title: j['title'] ?? '',
    description: j['description'] ?? '',
    subjectId: '${j['subjectId'] ?? ''}',
    classId: '${j['classId'] ?? ''}',
    subject: j['subject'] ?? '',
    subjectCode: j['subjectCode'] ?? '',
    className: j['className'] ?? '',
    duration: j['duration'] ?? 15,
    maxAttempts: j['maxAttempts'] ?? 1,
    attemptsUsed: j['attemptsUsed'] ?? 0,
    passMark: j['passMark'] ?? 50,
    totalScore: j['totalScore'],
    startAt: j['startAt'],
    endAt: j['endAt'],
    totalQuestions:
        j['totalQuestions'] ?? (j['questions'] as List?)?.length ?? 0,
    totalPoints: j['totalPoints'] ?? 0,
    status: j['status'] ?? 'not_started',
    isUpcoming: j['isUpcoming'] ?? false,
    isOpen: j['isOpen'] ?? true,
    isClosed: j['isClosed'] ?? false,
    attemptsExhausted: j['attemptsExhausted'] ?? false,
    bestScore: j['bestScore'],
    bestPercentage: (j['bestPercentage'] as num?)?.toDouble(),
    lastSubmittedAt: j['lastSubmittedAt'],
    attemptNumber: j['attemptNumber'],
    deadlineAt: j['deadlineAt'],
    serverNow: j['serverNow'],
    questions: (j['questions'] as List? ?? const [])
        .map((q) => Question.fromJson(Map<String, dynamic>.from(q)))
        .toList(),
    icon: iconForSubjectCode(j['subjectCode']),
    color: colorForSeed('${j['subjectCode'] ?? j['subjectId'] ?? ''}'),
  );
}

/// "Your learning progress" completion counts, computed client-side from
/// the full assigned-quiz list rather than trusted from the server's
/// dashboard aggregate (`StudentDashboardStats.completedCount`/`todoCount`).
/// That aggregate only counts quizzes that are still actionable, so a quiz
/// that closed before the student ever attempted it silently drops out of
/// both buckets there — inflating the completion percentage to look like
/// 100% even when a quiz was missed.
class AssessmentProgress {
  final int completed;
  final int todo;
  const AssessmentProgress({required this.completed, required this.todo});

  int get total => completed + todo;
  double get percent => total == 0 ? 0.0 : completed / total;

  factory AssessmentProgress.fromAssessments(List<Assessment> all) {
    final completed = all.where((a) => a.lastSubmittedAt != null).length;
    return AssessmentProgress(completed: completed, todo: all.length - completed);
  }
}

/// Result of submitting a quiz, as returned by `POST
/// /student/quizzes/:id/submit`. The live API only ever returns this score
/// summary — no per-question correctness/explanations exist anywhere in the
/// backend. [reviewQuestions]/[reviewSelections] are demo-only: populated by
/// the local scorer in [AppRepository] when the API can't be reached, so the
/// review screen keeps working in demo mode but is simply unavailable
/// (buttons hidden) against the live API.
class SubmissionResult {
  final String submissionId;
  final int attemptNumber;
  final int score;
  final int totalPoints;
  final double percentage;
  final int passMark;
  final bool passed;

  final List<Question>? reviewQuestions;
  final List<String?>?
  reviewSelections; // selected option id per reviewQuestions[i], demo-only

  const SubmissionResult({
    this.submissionId = '',
    this.attemptNumber = 1,
    required this.score,
    required this.totalPoints,
    required this.percentage,
    required this.passMark,
    required this.passed,
    this.reviewQuestions,
    this.reviewSelections,
  });

  PerformanceLevel get level => levelForPercent(percentage);

  factory SubmissionResult.fromJson(Map<String, dynamic> j) => SubmissionResult(
    submissionId: '${j['submissionId'] ?? ''}',
    attemptNumber: j['attemptNumber'] ?? 1,
    score: j['score'] ?? 0,
    totalPoints: j['totalPoints'] ?? 0,
    percentage: (j['percentage'] as num?)?.toDouble() ?? 0,
    passMark: j['passMark'] ?? 50,
    passed: j['passed'] ?? false,
  );
}

/// `/me` — flat, shared by both Student and Teacher; role-specific data
/// (faculty/major/academic year, department, etc.) lives on separate
/// profile tables the mobile app has no route to fetch directly, so the
/// repository fills in what it can from the student's own course list.
class Student {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String? major;
  final String? className;
  final String? academicYear;

  const Student({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.major,
    this.className,
    this.academicYear,
  });

  String get name => '$firstName $lastName'.trim();

  factory Student.fromJson(Map<String, dynamic> j) => Student(
    id: '${j['id']}',
    username: j['username'] ?? '',
    firstName: j['first_name'] ?? '',
    lastName: j['last_name'] ?? '',
    email: j['email'] ?? '',
  );

  Student copyWithCourse({
    String? major,
    String? className,
    String? academicYear,
  }) => Student(
    id: id,
    username: username,
    firstName: firstName,
    lastName: lastName,
    email: email,
    major: major,
    className: className,
    academicYear: academicYear,
  );
}

enum UserRole { student, teacher }

/// Minimal identity returned right after login — just enough for the login
/// screen to decide which home layout to open. Each role's full profile is
/// loaded separately by its own profile screen.
class AuthResult {
  final UserRole role;
  final String id;
  final String name;

  const AuthResult({required this.role, required this.id, required this.name});
}

/// `/me`, same shape as [Student]. Laravel's teacher_profiles table has no
/// department/title fields exposed on this endpoint, so the profile screen
/// shows account fields (username/status) instead.
class Teacher {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String status;

  const Teacher({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.status = '',
  });

  String get name => '$firstName $lastName'.trim();

  factory Teacher.fromJson(Map<String, dynamic> j) => Teacher(
    id: '${j['id']}',
    username: j['username'] ?? '',
    firstName: j['first_name'] ?? '',
    lastName: j['last_name'] ?? '',
    email: j['email'] ?? '',
    status: j['status'] == true || j['status'] == 1
        ? 'Active'
        : (j['status']?.toString() ?? ''),
  );
}

/// One student's result on one quiz, as seen from the teacher's "All
/// Results" view — a `GET /teacher/quizzes/{id}/scores` row joined with its
/// parent quiz's subject/class/points from the `/teacher/quizzes` list
/// fetched alongside it (see [AppRepository.fetchAllResults]).
class TeacherResult {
  final String submissionId;
  final String quizId;
  final String studentId;
  final String studentName;
  final String subjectId;
  final String subjectName;
  final String className;
  final String submittedAt;
  final int mcqScore;
  final int? essayScore;
  final bool essayNeedsGrade;
  final int totalPoints;
  final int passMark;
  final bool passed;
  final int tabSwitchCount;

  /// Demo-only: selected option id per question of the quiz, in question
  /// order — powers the "view this student's answers" drill-down in demo
  /// mode. The live scores endpoint has no per-question answer data at all,
  /// so this stays empty (and the drill-down hidden) against the real API.
  final List<String?> answers;

  const TeacherResult({
    this.submissionId = '',
    this.quizId = '',
    required this.studentId,
    required this.studentName,
    this.subjectId = '',
    required this.subjectName,
    required this.className,
    required this.submittedAt,
    this.mcqScore = 0,
    this.essayScore,
    this.essayNeedsGrade = false,
    this.totalPoints = 0,
    this.passMark = 50,
    this.passed = false,
    this.tabSwitchCount = 0,
    this.answers = const [],
  });

  int get score => mcqScore + (essayScore ?? 0);
  double get percentage => totalPoints > 0 ? (score / totalPoints * 100) : 0;
  PerformanceLevel get level => levelForPercent(percentage);
  Color get color => level.color;
}

/// `GET /student/results` row — one past quiz submission.
class HistoryItem {
  final String id;
  final String quizId;
  final String quizTitle;
  final String subjectId;
  final String classId;
  final String subject;
  final String className;
  final int attemptNumber;
  final String submittedAt;
  final String status; // 'submitted' | 'graded'
  final int score;
  final int totalPoints;
  final double percentage;
  final int passMark;
  final bool passed;

  const HistoryItem({
    this.id = '',
    this.quizId = '',
    this.quizTitle = '',
    this.subjectId = '',
    this.classId = '',
    required this.subject,
    this.className = '',
    this.attemptNumber = 1,
    required this.submittedAt,
    this.status = 'submitted',
    required this.score,
    this.totalPoints = 0,
    required this.percentage,
    this.passMark = 50,
    this.passed = false,
  });

  PerformanceLevel get level => levelForPercent(percentage);
  Color get color => level.color;

  factory HistoryItem.fromJson(Map<String, dynamic> j) => HistoryItem(
    id: '${j['id'] ?? ''}',
    quizId: '${j['quizId'] ?? ''}',
    quizTitle: j['quizTitle'] ?? '',
    subjectId: '${j['subjectId'] ?? ''}',
    classId: '${j['classId'] ?? ''}',
    subject: j['subject'] ?? '',
    className: j['className'] ?? '',
    attemptNumber: j['attemptNumber'] ?? 1,
    submittedAt: j['submittedAt'] ?? '',
    status: j['status'] ?? 'submitted',
    score: j['score'] ?? 0,
    totalPoints: j['totalPoints'] ?? 0,
    percentage: (j['percentage'] as num?)?.toDouble() ?? 0,
    passMark: j['passMark'] ?? 50,
    passed: j['passed'] ?? false,
  );
}

/// `GET /student/notifications` row.
class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? actionUrl;
  final bool isRead;
  final String createdAt;

  const AppNotification({
    this.id = '',
    this.type = '',
    required this.title,
    required this.message,
    this.actionUrl,
    required this.isRead,
    required this.createdAt,
  });

  IconData get icon => iconForNotificationType(type);
  Color get color => colorForNotificationType(type);
  String get time => formatRelativeTime(createdAt);

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id: '${j['id'] ?? ''}',
    type: j['type'] ?? '',
    title: j['title'] ?? '',
    message: j['message'] ?? '',
    actionUrl: j['actionUrl'],
    isRead: j['isRead'] ?? false,
    createdAt: j['createdAt'] ?? '',
  );
}

/// `GET /teacher/dashboard` → one `recentQuizzes` row.
class TeacherQuizSummary {
  final String id;
  final String title;
  final String subject;
  final String className;
  final String statusText;
  final int questionsCount;
  final int duration;
  final int submittedCount;
  final int totalStudents;

  const TeacherQuizSummary({
    required this.id,
    required this.title,
    this.subject = '',
    this.className = '',
    this.statusText = '',
    this.questionsCount = 0,
    this.duration = 0,
    this.submittedCount = 0,
    this.totalStudents = 0,
  });

  double get submissionRate =>
      totalStudents > 0 ? submittedCount / totalStudents * 100 : 0;

  factory TeacherQuizSummary.fromJson(Map<String, dynamic> j) =>
      TeacherQuizSummary(
        id: '${j['id'] ?? ''}',
        title: j['title'] ?? '',
        subject: j['subject'] ?? '',
        className: j['className'] ?? '',
        statusText: j['statusText'] ?? '',
        questionsCount: j['questionsCount'] ?? 0,
        duration: j['duration'] ?? 0,
        submittedCount: j['submittedCount'] ?? 0,
        totalStudents: j['totalStudents'] ?? 0,
      );
}

/// `GET /teacher/dashboard` → one `upcomingQuizzes` row.
class TeacherUpcomingQuiz {
  final String id;
  final String title;
  final String subject;
  final String className;
  final String status;
  final String? startAt; // 'Y-m-d\TH:i', nullable
  final String? endAt;

  const TeacherUpcomingQuiz({
    required this.id,
    required this.title,
    this.subject = '',
    this.className = '',
    this.status = '',
    this.startAt,
    this.endAt,
  });

  factory TeacherUpcomingQuiz.fromJson(Map<String, dynamic> j) =>
      TeacherUpcomingQuiz(
        id: '${j['id'] ?? ''}',
        title: j['title'] ?? '',
        subject: j['subject'] ?? '',
        className: j['className'] ?? '',
        status: j['status'] ?? '',
        startAt: j['startAt'],
        endAt: j['endAt'],
      );
}

/// `GET /teacher/dashboard` → one `needsAttention` row.
///
/// [score] is a raw point sum (`mcq_score + essay_score`) from the backend —
/// it is NOT a percentage and must never be rendered with a `%` suffix.
class NeedsAttentionEntry {
  final String name;
  final String className;
  final String subject;
  final int score;

  const NeedsAttentionEntry({
    required this.name,
    this.className = '',
    this.subject = '',
    this.score = 0,
  });

  factory NeedsAttentionEntry.fromJson(Map<String, dynamic> j) =>
      NeedsAttentionEntry(
        name: j['name'] ?? '',
        className: j['className'] ?? '',
        subject: j['subject'] ?? '',
        score: (j['score'] as num?)?.toInt() ?? 0,
      );
}

/// `GET /teacher/dashboard` response.
class TeacherDashboardStats {
  final int classesCount;
  final int studentsCount;
  final int activeQuizzesCount;
  final int pendingEssaysCount;
  final double averageScore;
  final List<TeacherQuizSummary> recentQuizzes;
  final List<NeedsAttentionEntry> needsAttention;
  final List<TeacherUpcomingQuiz> upcomingQuizzes;

  const TeacherDashboardStats({
    this.classesCount = 0,
    this.studentsCount = 0,
    this.activeQuizzesCount = 0,
    this.pendingEssaysCount = 0,
    this.averageScore = 0,
    this.recentQuizzes = const [],
    this.needsAttention = const [],
    this.upcomingQuizzes = const [],
  });

  factory TeacherDashboardStats.fromJson(
    Map<String, dynamic> j,
  ) => TeacherDashboardStats(
    classesCount: j['classesCount'] ?? 0,
    studentsCount: j['studentsCount'] ?? 0,
    activeQuizzesCount: j['activeQuizzesCount'] ?? 0,
    pendingEssaysCount: j['pendingEssaysCount'] ?? 0,
    averageScore: (j['averageScore'] as num?)?.toDouble() ?? 0,
    recentQuizzes: (j['recentQuizzes'] as List? ?? const [])
        .map((q) => TeacherQuizSummary.fromJson(Map<String, dynamic>.from(q)))
        .toList(),
    needsAttention: (j['needsAttention'] as List? ?? const [])
        .map((n) => NeedsAttentionEntry.fromJson(Map<String, dynamic>.from(n)))
        .toList(),
    upcomingQuizzes: (j['upcomingQuizzes'] as List? ?? const [])
        .map((u) => TeacherUpcomingQuiz.fromJson(Map<String, dynamic>.from(u)))
        .toList(),
  );
}

/// `GET /student/dashboard` → one `announcements` row (teacher feedback).
class Announcement {
  final String id;
  final String message;
  final String teacherName;
  final String sentAt; // 'Y-m-d\TH:i:s'

  const Announcement({
    this.id = '',
    required this.message,
    this.teacherName = '',
    this.sentAt = '',
  });

  String get time => formatRelativeTime(sentAt);

  factory Announcement.fromJson(Map<String, dynamic> j) => Announcement(
    id: '${j['id'] ?? ''}',
    message: j['message'] ?? '',
    teacherName: j['teacherName'] ?? '',
    sentAt: j['sentAt'] ?? '',
  );
}

/// `GET /student/dashboard` → one `dueSoon`/`recentQuizzes` row.
class StudentQuizSummary {
  final String id;
  final String title;
  final String subject;
  final String subjectId;
  final String classId;
  final String className;
  final int duration;
  final int totalQuestions;
  final String? startAt; // 'Y-m-d\TH:i', nullable
  final String? endAt;
  final bool isUpcoming;
  final bool isClosed;
  final bool attemptsExhausted;
  final int attemptsUsed;
  final int maxAttempts;
  final String? publishedAt; // 'Y-m-d\TH:i:s', recentQuizzes only

  const StudentQuizSummary({
    required this.id,
    required this.title,
    this.subject = '',
    this.subjectId = '',
    this.classId = '',
    this.className = '',
    this.duration = 0,
    this.totalQuestions = 0,
    this.startAt,
    this.endAt,
    this.isUpcoming = false,
    this.isClosed = false,
    this.attemptsExhausted = false,
    this.attemptsUsed = 0,
    this.maxAttempts = 1,
    this.publishedAt,
  });

  IconData get icon => iconForSubjectCode(subject);
  Color get color => colorForSeed(subjectId.isNotEmpty ? subjectId : subject);

  factory StudentQuizSummary.fromJson(Map<String, dynamic> j) =>
      StudentQuizSummary(
        id: '${j['id'] ?? ''}',
        title: j['title'] ?? '',
        subject: j['subject'] ?? '',
        subjectId: '${j['subjectId'] ?? ''}',
        classId: '${j['classId'] ?? ''}',
        className: j['className'] ?? '',
        duration: j['duration'] ?? 0,
        totalQuestions: j['totalQuestions'] ?? 0,
        startAt: j['startAt'],
        endAt: j['endAt'],
        isUpcoming: j['isUpcoming'] ?? false,
        isClosed: j['isClosed'] ?? false,
        attemptsExhausted: j['attemptsExhausted'] ?? false,
        attemptsUsed: j['attemptsUsed'] ?? 0,
        maxAttempts: j['maxAttempts'] ?? 1,
        publishedAt: j['publishedAt'],
      );
}

/// `GET /student/dashboard` response.
class StudentDashboardStats {
  final int todoCount;
  final int completedCount;
  final double averageScore;
  final int enrolledSubjectsCount;
  final List<StudentQuizSummary> dueSoon;
  final List<StudentQuizSummary> recentQuizzes;
  final List<Announcement> announcements;

  const StudentDashboardStats({
    this.todoCount = 0,
    this.completedCount = 0,
    this.averageScore = 0,
    this.enrolledSubjectsCount = 0,
    this.dueSoon = const [],
    this.recentQuizzes = const [],
    this.announcements = const [],
  });

  factory StudentDashboardStats.fromJson(
    Map<String, dynamic> j,
  ) => StudentDashboardStats(
    todoCount: j['todoCount'] ?? 0,
    completedCount: j['completedCount'] ?? 0,
    averageScore: (j['averageScore'] as num?)?.toDouble() ?? 0,
    enrolledSubjectsCount: j['enrolledSubjectsCount'] ?? 0,
    dueSoon: (j['dueSoon'] as List? ?? const [])
        .map((q) => StudentQuizSummary.fromJson(Map<String, dynamic>.from(q)))
        .toList(),
    recentQuizzes: (j['recentQuizzes'] as List? ?? const [])
        .map((q) => StudentQuizSummary.fromJson(Map<String, dynamic>.from(q)))
        .toList(),
    announcements: (j['announcements'] as List? ?? const [])
        .map((a) => Announcement.fromJson(Map<String, dynamic>.from(a)))
        .toList(),
  );
}

/// A single day's-worth entry on the Schedule screen, as returned by
/// `GET /teacher/calendar` and `GET /student/calendar` — both endpoints
/// return quizzes overlapping the requested month in this same shape.
class ScheduleItem {
  final String id;
  final String title;
  final String status;
  final String subjectName;
  final String subjectCode;
  final String className;
  final DateTime startDate;
  final DateTime endDate;
  final String? startAt;
  final String? endAt;
  final int totalQuestions;
  final int totalPoints;
  final int duration; // minutes

  const ScheduleItem({
    required this.id,
    required this.title,
    required this.status,
    required this.subjectName,
    required this.subjectCode,
    required this.className,
    required this.startDate,
    required this.endDate,
    this.startAt,
    this.endAt,
    this.totalQuestions = 0,
    this.totalPoints = 0,
    this.duration = 0,
  });

  /// Whether [day] falls within this item's `[startDate, endDate]` range,
  /// ignoring time-of-day — used to filter the month's items down to the
  /// list shown for whichever day is selected on the calendar.
  bool coversDate(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(startDate) && !d.isAfter(endDate);
  }

  factory ScheduleItem.fromJson(Map<String, dynamic> j) {
    final subject = j['subject'] as Map?;
    final classroom = j['class'] as Map?;
    DateTime parseDate(dynamic v) =>
        DateTime.tryParse('${v ?? ''}') ?? DateTime.now();
    return ScheduleItem(
      id: '${j['id']}',
      title: j['title'] ?? '',
      status: j['status'] ?? '',
      subjectName: '${subject?['name'] ?? ''}',
      subjectCode: '${subject?['code'] ?? ''}',
      className: '${classroom?['name'] ?? ''}',
      startDate: parseDate(j['startDate']),
      endDate: parseDate(j['endDate']),
      startAt: j['startAt'],
      endAt: j['endAt'],
      totalQuestions: j['totalQuestions'] ?? 0,
      totalPoints: j['totalPoints'] ?? 0,
      duration: j['duration'] ?? 0,
    );
  }
}
