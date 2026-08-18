import 'package:flutter/material.dart';

/// The API returns icon/color as simple strings (e.g. "android", "#2563EB").
/// These helpers translate that wire format to/from Flutter types so screens
/// never have to care whether data came from the network or from mock data.
IconData iconFromKey(String? key) => switch (key) {
      'android' => Icons.phone_android_rounded,
      'database' => Icons.storage_rounded,
      'web' => Icons.language_rounded,
      'software' => Icons.integration_instructions_rounded,
      'network' => Icons.hub_rounded,
      'assignment' => Icons.assignment_rounded,
      'alarm' => Icons.alarm_rounded,
      'result' => Icons.emoji_events_rounded,
      'announcement' => Icons.campaign_rounded,
      _ => Icons.school_rounded,
    };

String keyFromIcon(IconData icon) {
  final map = {
    Icons.phone_android_rounded: 'android',
    Icons.storage_rounded: 'database',
    Icons.language_rounded: 'web',
    Icons.integration_instructions_rounded: 'software',
    Icons.hub_rounded: 'network',
  };
  return map[icon] ?? 'default';
}

Color colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xFF2563EB);
  final h = hex.replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

String hexFromColor(Color c) => '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

enum PerformanceLevel { excellent, good, average, beginner }

extension PerformanceLevelX on PerformanceLevel {
  String get label => switch (this) {
        PerformanceLevel.excellent => 'Excellent',
        PerformanceLevel.good => 'Good',
        PerformanceLevel.average => 'Average',
        PerformanceLevel.beginner => 'Beginner',
      };

  Color get color => switch (this) {
        PerformanceLevel.excellent => const Color(0xFF10B981),
        PerformanceLevel.good => const Color(0xFF3B82F6),
        PerformanceLevel.average => const Color(0xFFF59E0B),
        PerformanceLevel.beginner => const Color(0xFFEF4444),
      };
}

class Subject {
  final String id;
  final String name;
  final String code;
  final String semester;
  final IconData icon;
  final Color color;
  final int totalAssessments;
  final int completed;
  final String classRoomId;

  const Subject({
    this.id = '',
    required this.name,
    required this.code,
    required this.semester,
    required this.icon,
    required this.color,
    required this.totalAssessments,
    required this.completed,
    this.classRoomId = '',
  });

  factory Subject.fromJson(Map<String, dynamic> j) => Subject(
        id: '${j['id']}',
        name: j['name'] ?? '',
        code: j['code'] ?? '',
        semester: j['semester'] ?? '',
        icon: iconFromKey(j['icon']),
        color: colorFromHex(j['color']),
        totalAssessments: j['totalAssessments'] ?? 0,
        completed: j['completed'] ?? 0,
        classRoomId: '${j['classRoomId'] ?? ''}',
      );
}

class ClassRoom {
  final String id;
  final String name;
  final String code;
  final IconData icon;
  final Color color;
  final int totalSubjects;

  const ClassRoom({
    this.id = '',
    required this.name,
    required this.code,
    required this.icon,
    required this.color,
    required this.totalSubjects,
  });

  factory ClassRoom.fromJson(Map<String, dynamic> j) => ClassRoom(
        id: '${j['id']}',
        name: j['name'] ?? '',
        code: j['code'] ?? '',
        icon: iconFromKey(j['icon']),
        color: colorFromHex(j['color']),
        totalSubjects: j['totalSubjects'] ?? 0,
      );
}

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const Question({
    this.id = '',
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        id: '${j['id']}',
        text: j['text'] ?? '',
        options: List<String>.from(j['options'] ?? const []),
        // Some APIs won't reveal the correct answer until after submission —
        // default to -1 (unknown) so the quiz screen never leaks it early.
        correctIndex: j['correctIndex'] ?? -1,
        explanation: j['explanation'] ?? '',
      );
}

class Assessment {
  final String id;
  final String subjectId;
  final String subject;
  final String title;
  final String lecturer;
  final int totalQuestions;
  final int timeLimitMinutes;
  final String availableDate;
  final String dueDate;
  final List<String> objectives;
  final List<Question> questions;
  final Color color;
  final IconData icon;

  const Assessment({
    this.id = '',
    this.subjectId = '',
    required this.subject,
    this.title = '',
    required this.lecturer,
    required this.totalQuestions,
    required this.timeLimitMinutes,
    required this.availableDate,
    required this.dueDate,
    required this.objectives,
    required this.questions,
    required this.color,
    required this.icon,
  });

  factory Assessment.fromJson(Map<String, dynamic> j) => Assessment(
        id: '${j['id']}',
        subjectId: '${j['subjectId'] ?? ''}',
        subject: j['subject'] ?? '',
        title: j['title'] ?? '',
        lecturer: j['lecturer'] ?? '',
        totalQuestions: j['totalQuestions'] ?? (j['questions'] as List?)?.length ?? 0,
        timeLimitMinutes: j['timeLimitMinutes'] ?? 15,
        availableDate: j['availableDate'] ?? '',
        dueDate: j['dueDate'] ?? '',
        objectives: List<String>.from(j['objectives'] ?? const []),
        questions: (j['questions'] as List? ?? const [])
            .map((q) => Question.fromJson(Map<String, dynamic>.from(q)))
            .toList(),
        color: colorFromHex(j['color']),
        icon: iconFromKey(j['icon']),
      );
}

/// Result of submitting a quiz, as returned by POST /assessments/:id/submit.
class SubmissionResult {
  final int correct;
  final int incorrect;
  final int totalQuestions;
  final int scorePercent;
  final PerformanceLevel level;
  final String feedback;
  final List<Question> reviewQuestions; // includes correctIndex + explanation
  final List<int?> studentAnswers;

  const SubmissionResult({
    required this.correct,
    required this.incorrect,
    required this.totalQuestions,
    required this.scorePercent,
    required this.level,
    required this.feedback,
    required this.reviewQuestions,
    required this.studentAnswers,
  });

  factory SubmissionResult.fromJson(Map<String, dynamic> j) => SubmissionResult(
        correct: j['correct'] ?? 0,
        incorrect: j['incorrect'] ?? 0,
        totalQuestions: j['totalQuestions'] ?? 0,
        scorePercent: j['scorePercent'] ?? 0,
        level: PerformanceLevel.values.firstWhere(
          (l) => l.name == j['level'],
          orElse: () => PerformanceLevel.average,
        ),
        feedback: j['feedback'] ?? '',
        reviewQuestions: (j['reviewQuestions'] as List? ?? const [])
            .map((q) => Question.fromJson(Map<String, dynamic>.from(q)))
            .toList(),
        studentAnswers: (j['studentAnswers'] as List? ?? const [])
            .map((a) => a == null ? null : a as int)
            .toList(),
      );
}

class Student {
  final String id;
  final String name;
  final String email;
  final String faculty;
  final String major;
  final String academicYear;

  const Student({
    required this.id,
    required this.name,
    required this.email,
    required this.faculty,
    required this.major,
    required this.academicYear,
  });

  factory Student.fromJson(Map<String, dynamic> j) => Student(
        id: '${j['id']}',
        name: j['name'] ?? '',
        email: j['email'] ?? '',
        faculty: j['faculty'] ?? '',
        major: j['major'] ?? '',
        academicYear: j['academicYear'] ?? '',
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

class Teacher {
  final String id;
  final String name;
  final String email;
  final String department;
  final String title;

  const Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.title,
  });

  factory Teacher.fromJson(Map<String, dynamic> j) => Teacher(
        id: '${j['id']}',
        name: j['name'] ?? '',
        email: j['email'] ?? '',
        department: j['department'] ?? '',
        title: j['title'] ?? '',
      );
}

/// One student's result on one quiz, as seen from the teacher's "All Results" view.
class TeacherResult {
  final String studentName;
  final String studentId;
  final String subjectId;
  final String subjectName;
  final String className;
  final String date;
  final int score;
  final String status;
  final Color color;
  final String assessmentId;
  final List<int?> answers;

  const TeacherResult({
    required this.studentName,
    required this.studentId,
    this.subjectId = '',
    required this.subjectName,
    required this.className,
    required this.date,
    required this.score,
    required this.status,
    required this.color,
    this.assessmentId = '',
    this.answers = const [],
  });

  factory TeacherResult.fromJson(Map<String, dynamic> j) => TeacherResult(
        studentName: j['studentName'] ?? '',
        studentId: j['studentId'] ?? '',
        subjectId: '${j['subjectId'] ?? ''}',
        subjectName: j['subjectName'] ?? '',
        className: j['className'] ?? '',
        date: j['date'] ?? '',
        score: j['score'] ?? 0,
        status: j['status'] ?? '',
        color: colorFromHex(j['color']),
        assessmentId: '${j['assessmentId'] ?? ''}',
        answers: (j['answers'] as List? ?? const []).map((a) => a == null ? null : a as int).toList(),
      );
}

class HistoryItem {
  final String subject;
  final String date;
  final int score;
  final String status;
  final Color color;

  const HistoryItem({
    required this.subject,
    required this.date,
    required this.score,
    required this.status,
    required this.color,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> j) => HistoryItem(
        subject: j['subject'] ?? '',
        date: j['date'] ?? '',
        score: j['score'] ?? 0,
        status: j['status'] ?? '',
        color: colorFromHex(j['color']),
      );
}

class AppNotification {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final bool unread;

  const AppNotification({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    required this.unread,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        title: j['title'] ?? '',
        subtitle: j['subtitle'] ?? '',
        time: j['time'] ?? '',
        icon: iconFromKey(j['icon']),
        color: colorFromHex(j['color']),
        unread: j['unread'] ?? false,
      );
}
