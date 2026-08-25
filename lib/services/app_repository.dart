import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import 'api_client.dart';
import 'session.dart';

/// Wraps a piece of data with whether it actually came from the live API
/// or from local demo/mock data (used when the backend can't be reached).
class RepoResult<T> {
  final T data;
  final bool isDemo;
  const RepoResult(this.data, {this.isDemo = false});
}

/// Single access point the UI talks to. Every method tries the real REST
/// API first; if the server is unreachable it transparently falls back to
/// mock data so the app is always usable, and flags the result as [isDemo]
/// so screens can surface a small "demo data" notice if they want to.
///
/// A handful of methods (fetchSubjects, fetchClassRooms, fetchAllResults)
/// are shared by both Student and Teacher screens but hit different,
/// role-scoped Laravel routes — [_isTeacher] reads the role [Session] saved
/// at login to pick the right one.
class AppRepository {
  AppRepository._();
  static final AppRepository instance = AppRepository._();
  final _api = ApiClient.instance;

  // Holds a demo-mode profile edit for the rest of this app run — there's no
  // backend to persist it to, but it shouldn't just be forgotten on the next
  // fetch either.
  Student? _profileOverride;
  Teacher? _teacherProfileOverride;

  Future<bool> _isTeacher() async => (await Session.loadRole()) == UserRole.teacher.name;

  // ---------------- Auth ----------------

  Future<RepoResult<AuthResult>> login({required String identifier, required String password, required bool remember}) async {
    try {
      final json = await _api.post('/login', auth: false, body: {
        'username': identifier,
        'password': password,
      });
      final user = Map<String, dynamic>.from(json['user'] ?? const {});
      final roleStr = '${user['role'] ?? ''}';
      if (roleStr.toLowerCase() == 'admin') {
        throw ApiException('Admin accounts aren\'t supported in this app — please use the web dashboard.');
      }
      final role = UserRole.values.firstWhere(
        (r) => r.name == roleStr.toLowerCase(),
        orElse: () => throw ApiException('Unrecognized account role "$roleStr".'),
      );
      final token = json['token'] as String;
      await Session.saveToken(token, remember: remember);
      await Session.saveRole(role.name, remember: remember);
      final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
      return RepoResult(AuthResult(role: role, id: '${user['id'] ?? ''}', name: name.isEmpty ? '${user['username'] ?? ''}' : name));
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      // No backend reachable — proceed straight into the demo experience,
      // picking a role from the entered id so both demo accounts are reachable:
      // a "TCH..." id signs in as the demo teacher, anything else as the demo student.
      await Session.saveToken('demo-token', remember: remember);
      final isTeacher = identifier.trim().toUpperCase().startsWith('TCH');
      await Session.saveRole(isTeacher ? UserRole.teacher.name : UserRole.student.name, remember: remember);
      return RepoResult(
        isTeacher
            ? const AuthResult(role: UserRole.teacher, id: MockData.teacherId, name: '${MockData.teacherFirstName} ${MockData.teacherLastName}')
            : const AuthResult(role: UserRole.student, id: MockData.studentId, name: '${MockData.studentFirstName} ${MockData.studentLastName}'),
        isDemo: true,
      );
    }
  }

  Future<void> logout() async => Session.clear();

  // ---------------- Class Rooms ----------------

  /// Laravel has no dedicated "classrooms" endpoint — this dedupes whichever
  /// course/class-assignment list the current role's own endpoint returns.
  Future<RepoResult<List<ClassRoom>>> fetchClassRooms() async {
    try {
      final teacher = await _isTeacher();
      final json = teacher ? await _api.get('/teacher/classes') : await _api.get('/student/courses');
      final rows = (json['data'] as List);
      final list = teacher
          ? _dedupeClassRooms(rows, idKey: 'class_id', nameKey: 'className')
          : _dedupeClassRooms(rows, idKey: 'classId', nameKey: 'className');
      return RepoResult(list);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(MockData.classRooms, isDemo: true);
    }
  }

  List<ClassRoom> _dedupeClassRooms(List<dynamic> rows, {required String idKey, required String nameKey}) {
    final counts = <String, int>{};
    final names = <String, String>{};
    for (final row in rows) {
      final m = Map<String, dynamic>.from(row);
      final id = '${m[idKey] ?? ''}';
      if (id.isEmpty) continue;
      counts[id] = (counts[id] ?? 0) + 1;
      names[id] = m[nameKey] ?? '';
    }
    return counts.entries
        .map((e) => ClassRoom(id: e.key, name: names[e.key] ?? '', icon: iconForSubjectCode(null), color: colorForSeed(e.key), totalSubjects: e.value))
        .toList();
  }

  // ---------------- Subjects ----------------

  /// `classRoomId`, when given, scopes the result to one class: for a
  /// student that's a client-side filter over `/student/courses`; for a
  /// teacher it's sourced from `/teacher/classes` instead of
  /// `/teacher/subjects`, since that's the list already shaped as
  /// (subject, class) pairs.
  Future<RepoResult<List<Subject>>> fetchSubjects({String? classRoomId}) async {
    try {
      final teacher = await _isTeacher();
      List<Subject> list;
      if (teacher) {
        if (classRoomId != null) {
          final json = await _api.get('/teacher/classes');
          final rows = (json['data'] as List)
              .map((r) => Map<String, dynamic>.from(r))
              .where((r) => '${r['class_id'] ?? ''}' == classRoomId);
          list = rows
              .map((r) => Subject(
                    id: '${r['subject_id'] ?? ''}',
                    classId: '${r['class_id'] ?? ''}',
                    name: r['subject'] ?? '',
                    code: r['subject_code'] ?? '',
                    className: r['className'] ?? '',
                    icon: iconForSubjectCode(r['subject_code']),
                    color: colorForSeed('${r['subject_code'] ?? r['subject_id'] ?? ''}'),
                  ))
              .toList();
        } else {
          final json = await _api.get('/teacher/subjects');
          list = (json['data'] as List).map((s) => Subject.fromTeacherSubjectJson(Map<String, dynamic>.from(s))).toList();
        }
      } else {
        final json = await _api.get('/student/courses');
        var rows = (json['data'] as List).map((r) => Map<String, dynamic>.from(r));
        if (classRoomId != null) rows = rows.where((r) => '${r['classId'] ?? ''}' == classRoomId);
        list = rows.map((r) => Subject.fromStudentCourseJson(r)).toList();
      }
      return RepoResult(list);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      var list = MockData.subjects;
      if (classRoomId != null) list = list.where((s) => s.classId == classRoomId).toList();
      return RepoResult(list, isDemo: true);
    }
  }

  // ---------------- Assessments ----------------

  /// Quiz metadata for the "Assessment Details"/"Instructions" screens,
  /// sourced from the list endpoint so merely viewing details doesn't start
  /// the timed attempt — only [startAssessment] does that.
  Future<RepoResult<Assessment>> fetchAssessment(String id) async {
    try {
      final json = await _api.get('/student/quizzes');
      final list = (json['data'] as List).map((a) => Assessment.fromJson(Map<String, dynamic>.from(a)));
      for (final a in list) {
        if (a.id == id) return RepoResult(a);
      }
      throw ApiException('Assessment not found.', statusCode: 404);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      final a = MockData.assessments.firstWhere((a) => a.id == id, orElse: () => MockData.assessments.first);
      return RepoResult(a, isDemo: true);
    }
  }

  /// Starts (or resumes) the timed attempt server-side and returns the full
  /// quiz with its questions. Laravel's `GET /student/quizzes/{id}` both
  /// fetches taking-questions AND starts the clock in one call, so this is
  /// only called right before the quiz-taking UI opens.
  Future<RepoResult<Assessment>> startAssessment(String id) async {
    try {
      final json = await _api.get('/student/quizzes/$id');
      return RepoResult(Assessment.fromJson(Map<String, dynamic>.from(json['quiz'])));
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      final a = MockData.assessments.firstWhere((a) => a.id == id, orElse: () => MockData.assessments.first);
      return RepoResult(a, isDemo: true);
    }
  }

  Future<RepoResult<List<Assessment>>> fetchAssessmentsBySubject(String subjectId) async {
    try {
      final json = await _api.get('/student/quizzes', query: {'subject_id': subjectId});
      final list = (json['data'] as List).map((a) => Assessment.fromJson(Map<String, dynamic>.from(a))).toList();
      return RepoResult(list);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      final list = MockData.assessments.where((a) => a.subjectId == subjectId).toList();
      return RepoResult(list, isDemo: true);
    }
  }

  /// "Upcoming" here means still actionable — not yet closed and not out of
  /// attempts — soonest due first; Laravel has no single endpoint for this,
  /// so it's derived client-side from the full quiz list.
  Future<RepoResult<List<Assessment>>> fetchUpcomingAssessments() async {
    try {
      final json = await _api.get('/student/quizzes');
      final all = (json['data'] as List).map((a) => Assessment.fromJson(Map<String, dynamic>.from(a))).toList();
      final actionable = all.where((a) => !a.isClosed && !a.attemptsExhausted).toList()
        ..sort((a, b) => (a.endAt ?? '').compareTo(b.endAt ?? ''));
      return RepoResult(actionable);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(MockData.assessments.take(2).toList(), isDemo: true);
    }
  }

  /// Submits structured per-question answers. The live API only ever
  /// returns a score summary — see [SubmissionResult] — so the demo-mode
  /// fallback is the only place that can produce a per-question review.
  Future<RepoResult<SubmissionResult>> submitAssessment({
    required String assessmentId,
    required List<StudentAnswer> answers,
    int tabSwitchCount = 0,
  }) async {
    try {
      final json = await _api.post('/student/quizzes/$assessmentId/submit', body: {
        'answers': answers.map((a) => a.toJson()).toList(),
        'tabSwitchCount': tabSwitchCount,
      });
      return RepoResult(SubmissionResult.fromJson(Map<String, dynamic>.from(json['result'])));
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(_scoreLocally(assessmentId, answers), isDemo: true);
    }
  }

  SubmissionResult _scoreLocally(String assessmentId, List<StudentAnswer> answers) {
    final assessment = MockData.assessments.firstWhere((a) => a.id == assessmentId, orElse: () => MockData.assessments.first);
    final questions = assessment.questions;
    final byQuestion = {for (final a in answers) a.questionId: a};

    var scoredPoints = 0;
    final selections = <String?>[]; // selected option id per question, for the demo review screen

    for (final q in questions) {
      final ans = byQuestion[q.id];
      final correctIds = q.options.where((o) => o.isCorrect).map((o) => o.id).toSet();
      bool correct;
      String? selectedForReview;

      if (q.isMatching) {
        correct = ans != null &&
            ans.matches.isNotEmpty &&
            ans.matches.length == q.leftItems.length &&
            ans.matches.every((m) => m.selectedRightPairId == m.leftPairId);
      } else if (q.multiSelect) {
        final picked = ans?.selectedOptionIds.toSet() ?? <String>{};
        correct = picked.isNotEmpty && picked.length == correctIds.length && picked.containsAll(correctIds);
        selectedForReview = picked.isEmpty ? null : picked.first;
      } else {
        selectedForReview = ans?.selectedOptionId;
        correct = selectedForReview != null && correctIds.contains(selectedForReview);
      }

      if (correct) scoredPoints += q.points;
      selections.add(selectedForReview);
    }

    final totalPoints = questions.fold<int>(0, (a, q) => a + q.points);
    final pct = totalPoints == 0 ? 0.0 : scoredPoints / totalPoints * 100;

    return SubmissionResult(
      score: scoredPoints,
      totalPoints: totalPoints,
      percentage: pct,
      passMark: assessment.passMark,
      passed: pct >= assessment.passMark,
      reviewQuestions: questions,
      reviewSelections: selections,
    );
  }

  // ---------------- History ----------------

  Future<RepoResult<List<HistoryItem>>> fetchHistory() async {
    try {
      final json = await _api.get('/student/results');
      final list = (json['data'] as List).map((h) => HistoryItem.fromJson(Map<String, dynamic>.from(h))).toList();
      return RepoResult(list);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(MockData.history, isDemo: true);
    }
  }

  // ---------------- Notifications ----------------

  Future<RepoResult<List<AppNotification>>> fetchNotifications() async {
    try {
      final json = await _api.get('/student/notifications');
      final list = (json['data'] as List).map((n) => AppNotification.fromJson(Map<String, dynamic>.from(n))).toList();
      return RepoResult(list);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(MockData.notifications, isDemo: true);
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _api.post('/student/notifications/read-all');
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      // demo mode: nothing to persist
    }
  }

  // ---------------- Profile ----------------

  Future<RepoResult<Student>> fetchProfile() async {
    try {
      final json = await _api.get('/me');
      var student = Student.fromJson(Map<String, dynamic>.from(json));
      // /me has no faculty/major/academic-year fields — best-effort pull
      // those from the student's first enrolled course.
      try {
        final coursesJson = await _api.get('/student/courses');
        final courses = (coursesJson['data'] as List);
        if (courses.isNotEmpty) {
          final first = Map<String, dynamic>.from(courses.first);
          student = student.copyWithCourse(
            major: first['major'],
            className: first['className'],
            academicYear: first['academicYear'],
          );
        }
      } catch (_) {
        // profile is still usable without this enrichment
      }
      return RepoResult(student);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(_profileOverride ?? _defaultDemoStudent, isDemo: true);
    }
  }

  Student get _defaultDemoStudent => const Student(
        id: MockData.studentId,
        username: MockData.studentUsername,
        firstName: MockData.studentFirstName,
        lastName: MockData.studentLastName,
        email: MockData.studentEmail,
        major: MockData.major,
        className: 'IT Year 3 - Class A',
        academicYear: MockData.academicYear,
      );

  /// Laravel has no dedicated profile-update route documented yet — this
  /// guesses `PATCH /me` (symmetric with the `GET /me` used by [fetchProfile])
  /// and falls back to an in-memory override so edits still stick for the
  /// rest of this run when the API can't be reached. If the real route turns
  /// out to be named differently, only this method needs to change.
  Future<RepoResult<Student>> updateProfile({required String firstName, required String lastName, required String email}) async {
    try {
      final json = await _api.patch('/me', body: {'first_name': firstName, 'last_name': lastName, 'email': email});
      final updated = Student.fromJson(Map<String, dynamic>.from(json));
      _profileOverride = updated;
      return RepoResult(updated);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      final current = _profileOverride ?? _defaultDemoStudent;
      final updated = Student(
        id: current.id,
        username: current.username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        major: current.major,
        className: current.className,
        academicYear: current.academicYear,
      );
      _profileOverride = updated;
      return RepoResult(updated, isDemo: true);
    }
  }

  /// No `/profile/preferences` route exists in Laravel — kept local-only.
  Future<void> updatePreferences({required bool notifications, required bool darkMode}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_notifications', notifications);
    await prefs.setBool('pref_dark_mode', darkMode);
  }

  // ---------------- Teacher ----------------

  Teacher get _defaultDemoTeacher => const Teacher(
        id: MockData.teacherId,
        username: MockData.teacherUsername,
        firstName: MockData.teacherFirstName,
        lastName: MockData.teacherLastName,
        email: MockData.teacherEmail,
        status: 'Active',
      );

  Future<RepoResult<Teacher>> fetchTeacherProfile() async {
    try {
      final json = await _api.get('/me');
      return RepoResult(Teacher.fromJson(Map<String, dynamic>.from(json)));
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(_teacherProfileOverride ?? _defaultDemoTeacher, isDemo: true);
    }
  }

  /// See [updateProfile] — same caveat about the guessed `PATCH /me` route.
  Future<RepoResult<Teacher>> updateTeacherProfile({required String firstName, required String lastName, required String email}) async {
    try {
      final json = await _api.patch('/me', body: {'first_name': firstName, 'last_name': lastName, 'email': email});
      final updated = Teacher.fromJson(Map<String, dynamic>.from(json));
      _teacherProfileOverride = updated;
      return RepoResult(updated);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      final current = _teacherProfileOverride ?? _defaultDemoTeacher;
      final updated = Teacher(
        id: current.id,
        username: current.username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        status: current.status,
      );
      _teacherProfileOverride = updated;
      return RepoResult(updated, isDemo: true);
    }
  }

  /// No aggregate "/teacher/results" route exists — this merges
  /// `GET /teacher/quizzes` with a `GET /teacher/quizzes/{id}/scores` call
  /// per quiz (N+1, but there's no bulk endpoint to use instead).
  Future<RepoResult<List<TeacherResult>>> fetchAllResults({String? subjectId}) async {
    try {
      final quizzesJson = await _api.get('/teacher/quizzes', query: {
        if (subjectId != null) 'subject_id': subjectId,
      });
      final quizzes = (quizzesJson['data'] as List).map((q) => Map<String, dynamic>.from(q)).toList();

      final results = <TeacherResult>[];
      for (final quiz in quizzes) {
        final quizId = '${quiz['id']}';
        final scoresJson = await _api.get('/teacher/quizzes/$quizId/scores');
        final quizTotalPoints = (scoresJson['totalPoints'] as num?)?.toInt() ?? (quiz['totalPoints'] ?? 0);
        final rows = (scoresJson['data'] as List).map((r) => Map<String, dynamic>.from(r));
        for (final r in rows) {
          results.add(TeacherResult(
            submissionId: '${r['id'] ?? ''}',
            quizId: quizId,
            studentId: r['studentId'] ?? '',
            studentName: r['name'] ?? '',
            subjectId: '${quiz['subject_id'] ?? ''}',
            subjectName: quiz['subjectName'] ?? '',
            className: quiz['className'] ?? '',
            submittedAt: r['submittedAt'] ?? '',
            mcqScore: r['mcqScore'] ?? 0,
            essayScore: r['essayScore'],
            essayNeedsGrade: r['essayNeedsGrade'] ?? false,
            totalPoints: quizTotalPoints,
            passMark: r['passMark'] ?? 50,
            passed: r['passed'] ?? false,
            tabSwitchCount: r['tabSwitchCount'] ?? 0,
          ));
        }
      }
      return RepoResult(results);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      var list = MockData.teacherResults;
      if (subjectId != null) list = list.where((r) => r.subjectId == subjectId).toList();
      return RepoResult(list, isDemo: true);
    }
  }
}
