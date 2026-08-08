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

  // ---------------- Auth ----------------

  Future<Student> login({required String identifier, required String password, required bool remember}) async {
    final json = await _api.post('/auth/login', auth: false, body: {
      'identifier': identifier,
      'password': password,
    });
    final token = json['token'] as String;
    await Session.saveToken(token, remember: remember);
    return Student.fromJson(Map<String, dynamic>.from(json['student']));
  }

  Future<Student> loginWithGoogle({required bool remember}) async {
    final json = await _api.post('/auth/google', auth: false);
    final token = json['token'] as String;
    await Session.saveToken(token, remember: remember);
    return Student.fromJson(Map<String, dynamic>.from(json['student']));
  }

  Future<void> logout() async => Session.clear();

  // ---------------- Subjects ----------------

  Future<RepoResult<List<Subject>>> fetchSubjects({String? query, String? semester}) async {
    try {
      final json = await _api.get('/subjects', query: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (semester != null && semester != 'All') 'semester': semester,
      });
      final list = (json as List).map((s) => Subject.fromJson(Map<String, dynamic>.from(s))).toList();
      return RepoResult(list);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(MockData.subjects, isDemo: true);
    }
  }

  // ---------------- Assessments ----------------

  Future<RepoResult<Assessment>> fetchAssessment(String id) async {
    try {
      final json = await _api.get('/assessments/$id');
      return RepoResult(Assessment.fromJson(Map<String, dynamic>.from(json)));
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(MockData.androidAssessment, isDemo: true);
    }
  }

  Future<RepoResult<List<Assessment>>> fetchUpcomingAssessments() async {
    try {
      final json = await _api.get('/assessments/upcoming');
      final list = (json as List).map((a) => Assessment.fromJson(Map<String, dynamic>.from(a))).toList();
      return RepoResult(list);
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult([MockData.androidAssessment], isDemo: true);
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
      return RepoResult(_scoreLocally(answers), isDemo: true);
    }
  }

  SubmissionResult _scoreLocally(List<int?> answers) {
    final questions = MockData.androidAssessment.questions;
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

  Future<RepoResult<Student>> fetchProfile() async {
    try {
      final json = await _api.get('/profile');
      return RepoResult(Student.fromJson(Map<String, dynamic>.from(json)));
    } on ApiException catch (e) {
      if (!e.isConnectivity) rethrow;
      return RepoResult(
        Student(
          id: MockData.studentId,
          name: MockData.studentName,
          email: 'sochea.ratanak@usea.edu.kh',
          faculty: MockData.faculty,
          major: MockData.major,
          academicYear: MockData.academicYear,
        ),
        isDemo: true,
      );
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
}
