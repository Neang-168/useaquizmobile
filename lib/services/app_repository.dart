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
class AppRepository {
  AppRepository._();
  static final AppRepository instance = AppRepository._();
  final _api = ApiClient.instance;

  // Holds a demo-mode profile edit for the rest of this app run — there's no
  // backend to persist it to, but it shouldn't just be forgotten on the next
  // fetch either.
  Student? _profileOverride;
  Teacher? _teacherProfileOverride;

  // ---------------- Auth ----------------

  Future<RepoResult<AuthResult>> login({required String identifier, required String password, required bool remember}) async {
    try {
      final json = await _api.post('/auth/login', auth: false, body: {
        'identifier': identifier,
        'password': password,
      });
      final token = json['token'] as String;
      await Session.saveToken(token, remember: remember);
      final role = UserRole.values.firstWhere((r) => r.name == json['role'], orElse: () => UserRole.student);
      final account = Map<String, dynamic>.from(json['student'] ?? json['teacher'] ?? const {});
      return RepoResult(AuthResult(role: role, id: '${account['id'] ?? ''}', name: account['name'] ?? ''));
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      // No backend reachable — proceed straight into the demo experience,
      // picking a role from the entered id so both demo accounts are reachable:
      // a "TCH..." id signs in as the demo teacher, anything else as the demo student.
      await Session.saveToken('demo-token', remember: remember);
      final isTeacher = identifier.trim().toUpperCase().startsWith('TCH');
      return RepoResult(
        isTeacher
            ? const AuthResult(role: UserRole.teacher, id: MockData.teacherId, name: MockData.teacherName)
            : const AuthResult(role: UserRole.student, id: MockData.studentId, name: MockData.studentName),
        isDemo: true,
      );
    }
  }

  Future<void> logout() async => Session.clear();

  // ---------------- Class Rooms ----------------

  Future<RepoResult<List<ClassRoom>>> fetchClassRooms() async {
    try {
      final json = await _api.get('/classrooms');
      final list = (json as List).map((c) => ClassRoom.fromJson(Map<String, dynamic>.from(c))).toList();
      return RepoResult(list);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(MockData.classRooms, isDemo: true);
    }
  }

  // ---------------- Subjects ----------------

  Future<RepoResult<List<Subject>>> fetchSubjects({String? query, String? semester, String? classRoomId}) async {
    try {
      final json = await _api.get('/subjects', query: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (semester != null && semester != 'All') 'semester': semester,
        if (classRoomId != null) 'classRoomId': classRoomId,
      });
      final list = (json as List).map((s) => Subject.fromJson(Map<String, dynamic>.from(s))).toList();
      return RepoResult(list);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      var list = MockData.subjects;
      if (classRoomId != null) list = list.where((s) => s.classRoomId == classRoomId).toList();
      return RepoResult(list, isDemo: true);
    }
  }

  // ---------------- Assessments ----------------

  Future<RepoResult<Assessment>> fetchAssessment(String id) async {
    try {
      final json = await _api.get('/assessments/$id');
      return RepoResult(Assessment.fromJson(Map<String, dynamic>.from(json)));
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      final a = MockData.assessments.firstWhere((a) => a.id == id, orElse: () => MockData.assessments.first);
      return RepoResult(a, isDemo: true);
    }
  }

  Future<RepoResult<List<Assessment>>> fetchAssessmentsBySubject(String subjectId) async {
    try {
      final json = await _api.get('/subjects/$subjectId/assessments');
      final list = (json as List).map((a) => Assessment.fromJson(Map<String, dynamic>.from(a))).toList();
      return RepoResult(list);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      final list = MockData.assessments.where((a) => a.subjectId == subjectId).toList();
      return RepoResult(list, isDemo: true);
    }
  }

  Future<RepoResult<List<Assessment>>> fetchUpcomingAssessments() async {
    try {
      final json = await _api.get('/assessments/upcoming');
      final list = (json as List).map((a) => Assessment.fromJson(Map<String, dynamic>.from(a))).toList();
      return RepoResult(list);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(MockData.assessments.take(2).toList(), isDemo: true);
    }
  }

  /// Submits answers server-side so scoring/explanations stay authoritative.
  /// Falls back to local scoring (using mock answer keys) in demo mode.
  Future<RepoResult<SubmissionResult>> submitAssessment({
    required String assessmentId,
    required List<int?> answers,
    required Duration timeSpent,
  }) async {
    try {
      final json = await _api.post('/assessments/$assessmentId/submit', body: {
        'answers': answers,
        'timeSpentSeconds': timeSpent.inSeconds,
      });
      return RepoResult(SubmissionResult.fromJson(Map<String, dynamic>.from(json)));
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(_scoreLocally(assessmentId, answers), isDemo: true);
    }
  }

  SubmissionResult _scoreLocally(String assessmentId, List<int?> answers) {
    final assessment =
        MockData.assessments.firstWhere((a) => a.id == assessmentId, orElse: () => MockData.assessments.first);
    final questions = assessment.questions;
    var correct = 0;
    for (var i = 0; i < questions.length && i < answers.length; i++) {
      if (answers[i] == questions[i].correctIndex) correct++;
    }
    final pct = questions.isEmpty ? 0 : (correct / questions.length * 100).round();
    final level = pct >= 90
        ? PerformanceLevel.excellent
        : pct >= 70
            ? PerformanceLevel.good
            : pct >= 50
                ? PerformanceLevel.average
                : PerformanceLevel.beginner;
    const feedback = {
      PerformanceLevel.excellent: 'Outstanding! You already have a strong grasp of the fundamentals.',
      PerformanceLevel.good: 'Solid work! A few concepts will get extra attention in class.',
      PerformanceLevel.average: 'A fair start — we\'ll cover the fundamentals before advanced topics.',
      PerformanceLevel.beginner: 'No worries, that\'s exactly why we run this assessment.',
    };
    return SubmissionResult(
      correct: correct,
      incorrect: questions.length - correct,
      totalQuestions: questions.length,
      scorePercent: pct,
      level: level,
      feedback: feedback[level]!,
      reviewQuestions: questions,
      studentAnswers: answers,
    );
  }

  // ---------------- History ----------------

  Future<RepoResult<List<HistoryItem>>> fetchHistory({String? query, String? status}) async {
    try {
      final json = await _api.get('/history', query: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (status != null && status != 'All') 'status': status,
      });
      final list = (json as List).map((h) => HistoryItem.fromJson(Map<String, dynamic>.from(h))).toList();
      return RepoResult(list);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(MockData.history, isDemo: true);
    }
  }

  // ---------------- Notifications ----------------

  Future<RepoResult<List<AppNotification>>> fetchNotifications() async {
    try {
      final json = await _api.get('/notifications');
      final list = (json as List).map((n) => AppNotification.fromJson(Map<String, dynamic>.from(n))).toList();
      return RepoResult(list);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(MockData.notifications, isDemo: true);
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _api.patch('/notifications/read-all');
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      // demo mode: nothing to persist
    }
  }

  // ---------------- Profile ----------------

  Student get _defaultDemoStudent => Student(
        id: MockData.studentId,
        name: MockData.studentName,
        email: 'sochea.ratanak@usea.edu.kh',
        faculty: MockData.faculty,
        major: MockData.major,
        academicYear: MockData.academicYear,
      );

  Future<RepoResult<Student>> fetchProfile() async {
    try {
      final json = await _api.get('/profile');
      return RepoResult(Student.fromJson(Map<String, dynamic>.from(json)));
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(_profileOverride ?? _defaultDemoStudent, isDemo: true);
    }
  }

  Future<RepoResult<Student>> updateProfile({required String name, required String email}) async {
    try {
      final json = await _api.patch('/profile', body: {'name': name, 'email': email});
      final updated = Student.fromJson(Map<String, dynamic>.from(json));
      _profileOverride = updated;
      return RepoResult(updated);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      final current = _profileOverride ?? _defaultDemoStudent;
      final updated = Student(
        id: current.id,
        name: name,
        email: email,
        faculty: current.faculty,
        major: current.major,
        academicYear: current.academicYear,
      );
      _profileOverride = updated;
      return RepoResult(updated, isDemo: true);
    }
  }

  Future<void> updatePreferences({required bool notifications, required bool darkMode}) async {
    try {
      await _api.patch('/profile/preferences', body: {'notifications': notifications, 'darkMode': darkMode});
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      // demo mode: nothing to persist
    }
  }

  // ---------------- Teacher ----------------

  Teacher get _defaultDemoTeacher => const Teacher(
        id: MockData.teacherId,
        name: MockData.teacherName,
        email: MockData.teacherEmail,
        department: MockData.teacherDepartment,
        title: MockData.teacherTitle,
      );

  Future<RepoResult<Teacher>> fetchTeacherProfile() async {
    try {
      final json = await _api.get('/teacher/profile');
      return RepoResult(Teacher.fromJson(Map<String, dynamic>.from(json)));
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(_teacherProfileOverride ?? _defaultDemoTeacher, isDemo: true);
    }
  }

  Future<RepoResult<Teacher>> updateTeacherProfile({required String name, required String email}) async {
    try {
      final json = await _api.patch('/teacher/profile', body: {'name': name, 'email': email});
      final updated = Teacher.fromJson(Map<String, dynamic>.from(json));
      _teacherProfileOverride = updated;
      return RepoResult(updated);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      final current = _teacherProfileOverride ?? _defaultDemoTeacher;
      final updated = Teacher(
        id: current.id,
        name: name,
        email: email,
        department: current.department,
        title: current.title,
      );
      _teacherProfileOverride = updated;
      return RepoResult(updated, isDemo: true);
    }
  }

  Future<RepoResult<List<TeacherResult>>> fetchAllResults({String? subjectId, String? query}) async {
    try {
      final json = await _api.get('/teacher/results', query: {
        if (subjectId != null) 'subjectId': subjectId,
        if (query != null && query.isNotEmpty) 'query': query,
      });
      final list = (json as List).map((r) => TeacherResult.fromJson(Map<String, dynamic>.from(r))).toList();
      return RepoResult(list);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      var list = MockData.teacherResults;
      if (subjectId != null) list = list.where((r) => r.subjectId == subjectId).toList();
      return RepoResult(list, isDemo: true);
    }
  }
}
