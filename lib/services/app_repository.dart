import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'api_client.dart';
import 'session.dart';

/// Single access point the UI talks to. Every method calls the real REST
/// API and lets [ApiException] propagate on failure — screens are
/// responsible for showing a retry-able error state.
///
/// A handful of methods (fetchSubjects, fetchClassRooms, fetchAllResults)
/// are shared by both Student and Teacher screens but hit different,
/// role-scoped Laravel routes — [_isTeacher] reads the role [Session] saved
/// at login to pick the right one.
class AppRepository {
  AppRepository._();
  static final AppRepository instance = AppRepository._();
  final _api = ApiClient.instance;

  Future<bool> _isTeacher() async =>
      (await Session.loadRole()) == UserRole.teacher.name;

  // ---------------- Auth ----------------

  Future<AuthResult> login({
    required String identifier,
    required String password,
    required bool remember,
  }) async {
    final json = await _api.post(
      '/login',
      auth: false,
      body: {'username': identifier, 'password': password},
    );
    final user = Map<String, dynamic>.from(json['user'] ?? const {});
    final roleStr = '${user['role'] ?? ''}';
    if (roleStr.toLowerCase() == 'admin') {
      throw ApiException(LocaleController.l.adminNotSupportedMessage);
    }
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleStr.toLowerCase(),
      orElse: () => throw ApiException(
        LocaleController.l.unrecognizedRoleMessage(roleStr),
      ),
    );
    final token = json['token'] as String;
    await Session.saveToken(token, remember: remember);
    await Session.saveRole(role.name, remember: remember);
    final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'
        .trim();
    return AuthResult(
      role: role,
      id: '${user['id'] ?? ''}',
      name: name.isEmpty ? '${user['username'] ?? ''}' : name,
    );
  }

  Future<void> logout() async => Session.clear();

  // ---------------- Class Rooms ----------------

  /// Laravel has no dedicated "classrooms" endpoint — this dedupes whichever
  /// course/class-assignment list the current role's own endpoint returns.
  Future<List<ClassRoom>> fetchClassRooms() async {
    final teacher = await _isTeacher();
    final json = teacher
        ? await _api.get('/teacher/classes')
        : await _api.get('/student/courses');
    final rows = (json['data'] as List);
    return teacher
        ? _dedupeClassRooms(rows, idKey: 'class_id', nameKey: 'className')
        : _dedupeClassRooms(rows, idKey: 'classId', nameKey: 'className');
  }

  List<ClassRoom> _dedupeClassRooms(
    List<dynamic> rows, {
    required String idKey,
    required String nameKey,
  }) {
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
        .map(
          (e) => ClassRoom(
            id: e.key,
            name: names[e.key] ?? '',
            icon: iconForSubjectCode(null),
            color: colorForSeed(e.key),
            totalSubjects: e.value,
          ),
        )
        .toList();
  }

  // ---------------- Schedule ----------------

  Future<List<ScheduleItem>> fetchSchedule({
    required int month,
    required int year,
  }) async {
    final teacher = await _isTeacher();
    final json = await _api.get(
      teacher ? '/teacher/calendar' : '/student/calendar',
      query: {'month': month, 'year': year},
    );
    return (json['data'] as List)
        .map((s) => ScheduleItem.fromJson(Map<String, dynamic>.from(s)))
        .toList();
  }

  // ---------------- Subjects ----------------

  /// `classRoomId`, when given, scopes the result to one class: for a
  /// student that's a client-side filter over `/student/courses`; for a
  /// teacher it's sourced from `/teacher/classes` instead of
  /// `/teacher/subjects`, since that's the list already shaped as
  /// (subject, class) pairs.
  Future<List<Subject>> fetchSubjects({String? classRoomId}) async {
    final teacher = await _isTeacher();
    if (teacher) {
      if (classRoomId != null) {
        final json = await _api.get('/teacher/classes');
        final rows = (json['data'] as List)
            .map((r) => Map<String, dynamic>.from(r))
            .where((r) => '${r['class_id'] ?? ''}' == classRoomId);
        return rows
            .map(
              (r) => Subject(
                id: '${r['subject_id'] ?? ''}',
                classId: '${r['class_id'] ?? ''}',
                name: r['subject'] ?? '',
                code: r['subject_code'] ?? '',
                className: r['className'] ?? '',
                icon: iconForSubjectCode(r['subject_code']),
                color: colorForSeed(
                  '${r['subject_code'] ?? r['subject_id'] ?? ''}',
                ),
              ),
            )
            .toList();
      }
      final json = await _api.get('/teacher/subjects');
      return (json['data'] as List)
          .map(
            (s) => Subject.fromTeacherSubjectJson(Map<String, dynamic>.from(s)),
          )
          .toList();
    }

    final json = await _api.get('/student/courses');
    var rows = (json['data'] as List).map((r) => Map<String, dynamic>.from(r));
    if (classRoomId != null) {
      rows = rows.where((r) => '${r['classId'] ?? ''}' == classRoomId);
    }
    return rows.map((r) => Subject.fromStudentCourseJson(r)).toList();
  }

  // ---------------- Assessments ----------------

  /// Quiz metadata for the "Assessment Details"/"Instructions" screens,
  /// sourced from the list endpoint so merely viewing details doesn't start
  /// the timed attempt — only [startAssessment] does that.
  Future<Assessment> fetchAssessment(String id) async {
    final json = await _api.get('/student/quizzes');
    final list = (json['data'] as List).map(
      (a) => Assessment.fromJson(Map<String, dynamic>.from(a)),
    );
    for (final a in list) {
      if (a.id == id) return a;
    }
    throw ApiException(
      LocaleController.l.assessmentNotFoundMessage,
      statusCode: 404,
    );
  }

  /// Starts (or resumes) the timed attempt server-side and returns the full
  /// quiz with its questions. Laravel's `GET /student/quizzes/{id}` both
  /// fetches taking-questions AND starts the clock in one call, so this is
  /// only called right before the quiz-taking UI opens.
  Future<Assessment> startAssessment(String id) async {
    final json = await _api.get('/student/quizzes/$id');
    return Assessment.fromJson(Map<String, dynamic>.from(json['quiz']));
  }

  Future<List<Assessment>> fetchAssessmentsBySubject(String subjectId) async {
    final json = await _api.get(
      '/student/quizzes',
      query: {'subject_id': subjectId},
    );
    return (json['data'] as List)
        .map((a) => Assessment.fromJson(Map<String, dynamic>.from(a)))
        .toList();
  }

  /// Quizzes for one specific (class, subject) enrollment — used by the
  /// course workspace, since a student can be enrolled in the same subject
  /// across more than one class.
  Future<List<Assessment>> fetchAssessmentsForClass({
    required String classId,
    required String subjectId,
  }) async {
    final json = await _api.get(
      '/student/quizzes',
      query: {'class_id': classId, 'subject_id': subjectId},
    );
    return (json['data'] as List)
        .map((a) => Assessment.fromJson(Map<String, dynamic>.from(a)))
        .toList();
  }

  /// The student's full assigned-quiz list, unfiltered — includes quizzes
  /// that already closed, whether or not the student ever attempted them.
  /// Used to compute accurate completion counts client-side (see
  /// [AssessmentProgress]) rather than trusting the dashboard's narrower
  /// "still actionable" aggregate.
  Future<List<Assessment>> fetchAllAssessments() async {
    final json = await _api.get('/student/quizzes');
    return (json['data'] as List)
        .map((a) => Assessment.fromJson(Map<String, dynamic>.from(a)))
        .toList();
  }

  /// "Upcoming" here means still actionable — not yet closed and not out of
  /// attempts — soonest due first.
  Future<List<Assessment>> fetchUpcomingAssessments() async {
    final all = await fetchAllAssessments();
    return all.where((a) => !a.isClosed && !a.attemptsExhausted).toList()
      ..sort((a, b) => (a.endAt ?? '').compareTo(b.endAt ?? ''));
  }

  /// Submits structured per-question answers. The live API only ever
  /// returns a score summary — see [SubmissionResult] — so its per-question
  /// review fields stay empty for real submissions.
  Future<SubmissionResult> submitAssessment({
    required String assessmentId,
    required List<StudentAnswer> answers,
    int tabSwitchCount = 0,
  }) async {
    final json = await _api.post(
      '/student/quizzes/$assessmentId/submit',
      body: {
        'answers': answers.map((a) => a.toJson()).toList(),
        'tabSwitchCount': tabSwitchCount,
      },
    );
    return SubmissionResult.fromJson(Map<String, dynamic>.from(json['result']));
  }

  // ---------------- History ----------------

  Future<List<HistoryItem>> fetchHistory() async {
    final json = await _api.get('/student/results');
    return (json['data'] as List)
        .map((h) => HistoryItem.fromJson(Map<String, dynamic>.from(h)))
        .toList();
  }

  /// Past submissions for one specific (class, subject) enrollment — used by
  /// the course workspace's "Results" section.
  Future<List<HistoryItem>> fetchHistoryForClass({
    required String classId,
    required String subjectId,
  }) async {
    final json = await _api.get(
      '/student/results',
      query: {'class_id': classId, 'subject_id': subjectId},
    );
    return (json['data'] as List)
        .map((h) => HistoryItem.fromJson(Map<String, dynamic>.from(h)))
        .toList();
  }

  // ---------------- Notifications ----------------

  Future<List<AppNotification>> fetchNotifications() async {
    final json = await _api.get('/student/notifications');
    return (json['data'] as List)
        .map((n) => AppNotification.fromJson(Map<String, dynamic>.from(n)))
        .toList();
  }

  /// Laravel's `/student/notifications` response also carries an
  /// `unreadCount` alongside `data` — this is what the home screen's bell
  /// icon badge reads.
  Future<int> fetchUnreadNotificationsCount() async {
    final json = await _api.get('/student/notifications');
    return (json['unreadCount'] as num?)?.toInt() ?? 0;
  }

  Future<void> markNotificationRead(String id) async {
    await _api.post('/student/notifications/$id/read');
  }

  Future<void> markAllNotificationsRead() async {
    await _api.post('/student/notifications/read-all');
  }

  // ---------------- Dashboards ----------------

  Future<TeacherDashboardStats> fetchTeacherDashboard() async {
    final json = await _api.get('/teacher/dashboard');
    return TeacherDashboardStats.fromJson(Map<String, dynamic>.from(json));
  }

  Future<StudentDashboardStats> fetchStudentDashboard() async {
    final json = await _api.get('/student/dashboard');
    return StudentDashboardStats.fromJson(Map<String, dynamic>.from(json));
  }

  // ---------------- Profile ----------------

  Future<Student> fetchProfile() async {
    final json = await _api.get('/me');
    return Student.fromJson(Map<String, dynamic>.from(json));
  }

  /// `PUT /me` returns the raw, un-nested `users` row (no `role`/
  /// `studentProfile` block), which isn't enough on its own to rebuild a
  /// full [Student] — so this re-fetches [fetchProfile] after saving rather
  /// than parsing the save response directly.
  Future<Student> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? nameKh,
    String? gender,
    String? dob,
    String? phone,
    String? address,
  }) async {
    await _api.put(
      '/me',
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'name_kh': nameKh,
        'gender': gender,
        'dob': dob,
        'phone': phone,
        'address': address,
      },
    );
    return fetchProfile();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _api.put(
      '/me/password',
      body: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      },
    );
  }

  /// No `/profile/preferences` route exists in Laravel — kept local-only.
  Future<void> updatePreferences({
    required bool notifications,
    required bool darkMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_notifications', notifications);
    await prefs.setBool('pref_dark_mode', darkMode);
  }

  // ---------------- Teacher ----------------

  Future<Teacher> fetchTeacherProfile() async {
    final json = await _api.get('/me');
    return Teacher.fromJson(Map<String, dynamic>.from(json));
  }

  /// `PUT /me` returns the raw `users` row wrapped as `{message, user}`, not
  /// the flat shape [Teacher.fromJson] expects — so this re-fetches
  /// [fetchTeacherProfile] after saving rather than parsing the response.
  Future<Teacher> updateTeacherProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    await _api.put(
      '/me',
      body: {'first_name': firstName, 'last_name': lastName, 'email': email},
    );
    return fetchTeacherProfile();
  }

  /// No aggregate "/teacher/results" route exists — this merges
  /// `GET /teacher/quizzes` with a `GET /teacher/quizzes/{id}/scores` call
  /// per quiz (N+1, but there's no bulk endpoint to use instead).
  Future<List<TeacherResult>> fetchAllResults({String? subjectId}) async {
    final quizzesJson = await _api.get(
      '/teacher/quizzes',
      query: {if (subjectId != null) 'subject_id': subjectId},
    );
    final quizzes = (quizzesJson['data'] as List)
        .map((q) => Map<String, dynamic>.from(q))
        .toList();

    final results = <TeacherResult>[];
    for (final quiz in quizzes) {
      final quizId = '${quiz['id']}';
      final scoresJson = await _api.get('/teacher/quizzes/$quizId/scores');
      final quizTotalPoints =
          (scoresJson['totalPoints'] as num?)?.toInt() ??
          (quiz['totalPoints'] ?? 0);
      final rows = (scoresJson['data'] as List).map(
        (r) => Map<String, dynamic>.from(r),
      );
      for (final r in rows) {
        results.add(
          TeacherResult(
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
          ),
        );
      }
    }
    return results;
  }
}
