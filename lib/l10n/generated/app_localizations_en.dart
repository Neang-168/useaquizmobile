// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pre-Study IT Knowledge Assessment';

  @override
  String get universityName => 'UNIVERSITY OF\nSOUTH-EAST ASIA';

  @override
  String get navHome => 'Home';

  @override
  String get navSubjects => 'My Course';

  @override
  String get navAssessments => 'Quiz';

  @override
  String get navHistory => 'History';

  @override
  String get navProfile => 'Profile';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navResults => 'Results';

  @override
  String get navClass => 'Class';

  @override
  String get retry => 'Retry';

  @override
  String get couldntLoadThis => 'Couldn\'t load this';

  @override
  String get logOut => 'Log Out';

  @override
  String get loggingOut => 'Logging out...';

  @override
  String get splashUniversityName => 'University of Southeast Asia';

  @override
  String get splashAppTitle => 'Pre-Study IT\nKnowledge Assessment';

  @override
  String get splashTagline => 'Know where you stand before class begins';

  @override
  String get loginUniversityName => 'UNIVERSITY OF SOUTH-EAST ASIA';

  @override
  String get loginWelcome =>
      'Welcome back! Sign in to continue your pre-study assessments.';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginStudentId => 'Student ID';

  @override
  String get loginStudentIdHint => 'ITU2023-0142';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginRememberMe => 'Remember me';

  @override
  String get loginButton => 'Login';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get preferencesTitle => 'Preferences';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get darkModeLabel => 'Dark Mode';

  @override
  String get languageLabel => 'Language';

  @override
  String get aboutTitle => 'About';

  @override
  String get appNameLabel => 'App';

  @override
  String get universityLabel => 'University';

  @override
  String get versionLabel => 'Version';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKhmer => 'ខ្មែរ';

  @override
  String get settingsNav => 'Settings';

  @override
  String get helpSupportNav => 'Help & Support';

  @override
  String get helpSupportTitle => 'Help & Support';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get contactUsTitle => 'Contact Us';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get faqQ1 => 'How do I take an assessment?';

  @override
  String get faqA1 =>
      'Open the Assessments tab, pick an upcoming assessment, and tap Start. Answer each question and submit before the due date shown on the assessment card.';

  @override
  String get faqQ2 => 'Where can I see my results?';

  @override
  String get faqA2 =>
      'Your score appears right after you submit an assessment, and every past attempt is saved under the History tab (or the History shortcut on your Profile).';

  @override
  String get faqQ3 => 'How do I check my class schedule?';

  @override
  String get faqA3 =>
      'Tap the Schedule shortcut on your Profile screen to see upcoming classes and assessment due dates in one place.';

  @override
  String get faqQ4 => 'I forgot my password. What do I do?';

  @override
  String get faqA4 =>
      'Contact your class teacher or the university IT office to have your password reset — accounts are managed centrally and can\'t be reset from within the app.';

  @override
  String get faqQ5 => 'Why aren\'t I receiving notifications?';

  @override
  String get faqA5 =>
      'Check that Notifications is turned on in Settings, and that notifications are allowed for this app in your device\'s system settings.';

  @override
  String couldntOpenApp(Object app) {
    return 'Couldn\'t open $app app';
  }

  @override
  String get editProfileLabel => 'Edit Profile';

  @override
  String get scheduleLabel => 'Schedule';

  @override
  String get historyLabel => 'History';

  @override
  String get resultsLabel => 'Results';

  @override
  String get classesLabel => 'Classes';

  @override
  String get majorLabel => 'Major';

  @override
  String get classLabel => 'Class';

  @override
  String get academicYearLabel => 'Academic Year';

  @override
  String get usernameLabel => 'Username';

  @override
  String get statusLabel => 'Status';

  @override
  String get roleLabel => 'Role';

  @override
  String get joinedLabel => 'Joined';

  @override
  String get genderLabel => 'Gender';

  @override
  String get dobLabel => 'Date of Birth';

  @override
  String get addressLabel => 'Address';

  @override
  String get khmerNameLabel => 'Khmer Name';

  @override
  String get facultyLabel => 'Faculty';

  @override
  String get degreeLabel => 'Degree';

  @override
  String get departmentLabel => 'Department';

  @override
  String get semesterLabel => 'Semester';

  @override
  String get termLabel => 'Term';

  @override
  String get shiftLabel => 'Shift';

  @override
  String get stageLabel => 'Stage';

  @override
  String get promotionLabel => 'Promotion';

  @override
  String get studentCodeLabel => 'Student Code';

  @override
  String get admissionDateLabel => 'Admission Date';

  @override
  String get enrollmentDateLabel => 'Enrollment Date';

  @override
  String get enrollmentStatusLabel => 'Enrollment Status';

  @override
  String get inactiveLabel => 'Inactive';

  @override
  String get personalInformationTitle => 'Personal Information';

  @override
  String get academicInformationTitle => 'Academic Information';

  @override
  String get noEnrollmentRecordTitle => 'No Enrollment Record';

  @override
  String get noEnrollmentRecordSubtitle =>
      'No enrollment record found yet. Contact your administrator if this looks wrong.';

  @override
  String get welcomeBack => 'Welcome back 👋';

  @override
  String get yourLearningProgress => 'Your Learning Progress';

  @override
  String completedOfTotal(Object completed, Object total) {
    return '$completed of $total completed';
  }

  @override
  String get continueLabel => 'Continue';

  @override
  String get noAssessmentsAssignedYet => 'No assessments assigned yet';

  @override
  String get allCaughtUpNothingDue => 'All caught up — nothing due right now';

  @override
  String get noProgressYet => 'No progress yet';

  @override
  String get noProgressYetSubtitle =>
      'Your completed and to-do assessments will show up here.';

  @override
  String get announcementsTitle => 'Announcements';

  @override
  String get noAnnouncements => 'No announcements';

  @override
  String get noAnnouncementsSubtitle =>
      'Feedback from your teachers will appear here.';

  @override
  String get upcomingAssessments => 'Upcoming Assessments';

  @override
  String get seeAll => 'See all';

  @override
  String get allCaughtUp => 'All caught up';

  @override
  String get noUpcomingSubtitle =>
      'No upcoming pre-study assessments right now.';

  @override
  String get enrolledSubjects => 'Enrolled Subjects';

  @override
  String get viewAll => 'View all';

  @override
  String subjectsEnrolledCount(Object count) {
    return '$count subjects enrolled';
  }

  @override
  String get myClassesTitle => 'My Classes';

  @override
  String get notEnrolledInAnyClasses =>
      'You\'re not enrolled in any classes yet.';

  @override
  String get activeLabel => 'Active';

  @override
  String get subjectCodeLabel => 'Subject Code';

  @override
  String get classGroupLabel => 'Class Group';

  @override
  String get quizzesCompletedLabel => 'Quizzes Completed';

  @override
  String get openWorkspace => 'Open Workspace';

  @override
  String get newlyPublishedQuizzes => 'Newly Published Quizzes';

  @override
  String get newBadgeLabel => 'New';

  @override
  String opensOnLabel(Object date) {
    return 'Opens $date';
  }

  @override
  String get closedLabel => 'Closed';

  @override
  String get noAttemptsLeftLabel => 'No Attempts Left';

  @override
  String get startExamLabel => 'Start Exam';

  @override
  String get completedAssessments => 'Completed Assessments';

  @override
  String get historyAction => 'History';

  @override
  String get noCompletedYet => 'No completed assessments yet';

  @override
  String get noCompletedYetSubtitle =>
      'Finished pre-study quizzes will appear here.';

  @override
  String get completedChartLabel => 'Completed';

  @override
  String get todoChartLabel => 'To do';

  @override
  String durationQuestionsDue(Object duration, Object questions, Object due) {
    return '$duration min · $questions questions$due';
  }

  @override
  String dueSuffix(Object date) {
    return ' · Due $date';
  }

  @override
  String get excellentLevel => 'Excellent';

  @override
  String get goodLevel => 'Good';

  @override
  String get averageLevel => 'Average';

  @override
  String get beginnerLevel => 'Beginner';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(Object count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(Object count) {
    return '${count}h ago';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(Object count) {
    return '${count}d ago';
  }

  @override
  String get mySubjects => 'My Subjects';

  @override
  String get assessmentsTitle => 'Assessments';

  @override
  String get subjectsAppBarTitle => 'Subjects';

  @override
  String get exploreSubjectsSubtitle =>
      'Explore subjects and their pre-study assessments';

  @override
  String get searchSubjectsHint => 'Search subjects...';

  @override
  String get allFilter => 'All';

  @override
  String get noSubjectsFound => 'No subjects found';

  @override
  String get tryDifferentSearch => 'Try a different search term or filter.';

  @override
  String get allQuizTitle => 'All Quiz';

  @override
  String preStudyQuizzesFor(Object subject) {
    return 'Pre-study quizzes for $subject';
  }

  @override
  String get noQuizzesYet => 'No quizzes yet';

  @override
  String get noQuizzesYetSubtitle =>
      'This subject has no pre-study quizzes yet.';

  @override
  String questionsDuration(Object questions, Object duration, Object due) {
    return '$questions questions · $duration min$due';
  }

  @override
  String get assessmentDetailsTitle => 'Assessment Details';

  @override
  String get preStudyAssessmentLabel => 'Pre-Study Assessment';

  @override
  String get totalQuestionsLabel => 'Total Questions';

  @override
  String totalQuestionsValue(Object count) {
    return '$count questions';
  }

  @override
  String get timeLimitLabel => 'Time Limit';

  @override
  String minutesValue(Object count) {
    return '$count minutes';
  }

  @override
  String get totalPointsPassMarkLabel => 'Total Points / Pass Mark';

  @override
  String pointsPassMarkValue(Object points, Object passMark) {
    return '$points pts · $passMark%';
  }

  @override
  String get attemptsLabel => 'Attempts';

  @override
  String attemptsValue(Object used, Object max) {
    return '$used/$max used';
  }

  @override
  String get availableFromLabel => 'Available From';

  @override
  String get anytimeLabel => 'Anytime';

  @override
  String get dueDateLabel => 'Due Date';

  @override
  String get noDeadlineLabel => 'No deadline';

  @override
  String get aboutThisQuiz => 'About This Quiz';

  @override
  String get instructionsTitle => 'Instructions';

  @override
  String get honestyNotice =>
      'This assessment measures your prior knowledge. It will not affect your final grade — answer honestly.';

  @override
  String get attemptsUsedUp => 'Attempts Used Up';

  @override
  String get assessmentClosed => 'Assessment Closed';

  @override
  String get assessmentNotYetAvailable => 'Not Yet Available';

  @override
  String get startAssessment => 'Start Assessment';

  @override
  String get instructionsAppBarTitle => 'Instructions';

  @override
  String get readCarefullySubtitle =>
      'Read the instructions carefully before you begin';

  @override
  String get beforeYouStart => 'Before you start';

  @override
  String ruleTimer(Object minutes, Object questions) {
    return 'You have $minutes minutes to complete $questions questions.';
  }

  @override
  String get ruleNoPause =>
      'The timer cannot be paused once the assessment starts.';

  @override
  String get ruleFlag =>
      'You may flag questions and revisit them before submitting.';

  @override
  String get ruleNoPassingScore =>
      'A passing score is not required — this is a diagnostic quiz.';

  @override
  String get ruleHonesty =>
      'Answer independently. This assessment is covered by the academic honesty policy.';

  @override
  String get honestyWarning =>
      'By starting, you confirm this work is entirely your own, in line with the university\'s Academic Honesty Policy.';

  @override
  String get startNowButton => 'I Understand, Start Now';

  @override
  String get noQuestionsAvailable => 'No questions available';

  @override
  String get noQuestionsAvailableSubtitle =>
      'This quiz has no questions to take right now.';

  @override
  String questionOfTotal(Object current, Object total) {
    return 'Question $current of $total';
  }

  @override
  String get flagged => 'Flagged';

  @override
  String get flagLabel => 'Flag';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get submit => 'Submit';

  @override
  String get submitting => 'Submitting...';

  @override
  String get submitDialogTitle => 'Submit Assessment?';

  @override
  String unansweredMessage(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'You have $count unanswered questions. You can\'t change your answers after submitting.',
      one:
          'You have 1 unanswered question. You can\'t change your answers after submitting.',
    );
    return '$_temp0';
  }

  @override
  String get allAnsweredMessage =>
      'You have answered all questions. You can\'t change your answers after submitting.';

  @override
  String get continueAssessment => 'Continue Assessment';

  @override
  String get leaveDialogTitle => 'Leave this assessment?';

  @override
  String get leaveDialogBody =>
      'Your timer keeps running even after you leave. If it runs out before you come back, your answers so far will be submitted automatically.';

  @override
  String get stay => 'Stay';

  @override
  String get leaveAnyway => 'Leave Anyway';

  @override
  String couldntSubmit(Object error) {
    return 'Couldn\'t submit: $error';
  }

  @override
  String get assessmentComplete => 'Assessment Complete';

  @override
  String get overallScore => 'Overall Score';

  @override
  String get scoreLabel => 'Score';

  @override
  String get passMarkLabel => 'Pass Mark';

  @override
  String get passed => 'Passed';

  @override
  String get notPassed => 'Not Passed';

  @override
  String get reviewUnavailable =>
      'A per-question answer review isn\'t available yet — only your overall score is returned.';

  @override
  String get viewReview => 'View Review';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get answerReviewTitle => 'Answer Review';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get unanswered => 'Unanswered';

  @override
  String get matchingReviewUnavailable =>
      'Matching-question review isn\'t shown in this simplified demo view.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsSubtitle => 'You\'re all caught up!';

  @override
  String get closeAction => 'Close';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get yourDetails => 'Your details';

  @override
  String get facultyNote =>
      'Faculty, major, and academic year are set by the university and can\'t be changed here.';

  @override
  String get accountStatusNote =>
      'Your account status is set by the university and can\'t be changed here.';

  @override
  String get firstName => 'First Name';

  @override
  String get firstNameHint => 'Your first name';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get lastName => 'Last Name';

  @override
  String get lastNameHint => 'Your last name';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get emailHint => 'you@usea.edu.kh';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String couldntSaveChanges(Object error) {
    return 'Couldn\'t save changes: $error';
  }

  @override
  String get khmerNameHint => 'e.g. សុខ វិសាល';

  @override
  String get phoneHint => '012 345 678';

  @override
  String get addressHint => 'Street, city, country';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get selectGenderHint => 'Select gender';

  @override
  String get selectDobHint => 'Select date of birth';

  @override
  String get changePasswordLabel => 'Change Password';

  @override
  String get changePasswordSubtitle => 'Manage your account security';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get currentPasswordHint => 'Current password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get newPasswordHint => 'Minimum 8 characters';

  @override
  String get confirmNewPasswordLabel => 'Confirm New Password';

  @override
  String get confirmNewPasswordHint => 'Repeat new password';

  @override
  String get updatePasswordButton => 'Update Password';

  @override
  String get missingPasswordFields => 'Please fill in all password fields.';

  @override
  String get passwordTooShort => 'New password must be at least 8 characters.';

  @override
  String get passwordsDoNotMatch => 'New password and confirmation must match.';

  @override
  String get passwordChangedMessage => 'Your password was updated.';

  @override
  String couldntChangePassword(Object error) {
    return 'Couldn\'t change password: $error';
  }

  @override
  String get perQuestionUnavailable => 'Per-question breakdown unavailable';

  @override
  String get perQuestionUnavailableSubtitle =>
      'The API only returns each student\'s overall score, not their answer to every question, so this view can\'t be built from live data.';

  @override
  String get scheduleAppBarTitle => 'Schedule';

  @override
  String get scheduleSectionTitle => 'Schedule';

  @override
  String get noDataTitle => 'No Data';

  @override
  String get noDataSubtitle => 'Nothing scheduled for this day.';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get classesCountLabel => 'Classes';

  @override
  String get studentsLabel => 'Students';

  @override
  String get activeQuizzesLabel => 'Active Quizzes';

  @override
  String get pendingEssaysLabel => 'Pending Essays';

  @override
  String get averageScoreLabel => 'Average Score';

  @override
  String get classPerformance => 'Class Performance';

  @override
  String get remainingTo100 => 'Remaining to 100%';

  @override
  String get submissionRatesTitle => 'Submission Rates';

  @override
  String get noRecentQuizzes => 'No recent quizzes';

  @override
  String get noRecentQuizzesSubmissionSubtitle =>
      'Submission rates will appear here once quizzes are published.';

  @override
  String get recentQuizzesTitle => 'Recent Quizzes';

  @override
  String get noRecentQuizzesSubtitle =>
      'Quizzes you publish will show up here.';

  @override
  String get needsAttentionTitle => 'Needs Attention';

  @override
  String get rawPointTotalsNote => 'Raw point totals — not percentages';

  @override
  String get noStudentsFlagged => 'No students currently flagged';

  @override
  String get noStudentsFlaggedSubtitle =>
      'Students scoring below the pass mark will appear here.';

  @override
  String get upcomingQuizzesTitle => 'Upcoming Quizzes';

  @override
  String get nothingScheduled => 'Nothing scheduled';

  @override
  String get nothingScheduledSubtitle => 'Upcoming quizzes will appear here.';

  @override
  String get noScheduleSet => 'No schedule set';

  @override
  String dueDatePrefix(Object date) {
    return 'Due $date';
  }

  @override
  String submittedCount(Object submitted, Object total) {
    return '$submitted/$total submitted';
  }

  @override
  String ptsLabel(Object count) {
    return '$count pts';
  }

  @override
  String get assessmentHistoryTitle => 'Assessment History';

  @override
  String get trackHistorySubtitle =>
      'Track all your completed pre-study assessments';

  @override
  String get searchBySubjectHint => 'Search by subject...';

  @override
  String get historyAppBarTitle => 'History';

  @override
  String get noHistoryFound => 'No history found';

  @override
  String get noHistoryFoundSubtitle =>
      'Completed assessments will show up here.';

  @override
  String get allResultsTitle => 'All Results';

  @override
  String get everyStudentResultSubtitle =>
      'Every student\'s quiz result across all classes';

  @override
  String get searchStudentSubjectHint => 'Search by student or subject...';

  @override
  String get resultsAppBarTitle => 'Results';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get myClassRoomsTitle => 'My Class Rooms';

  @override
  String get selectClassRoomSubtitle =>
      'Select a class room to view its subjects';

  @override
  String get searchClassRoomsHint => 'Search class rooms...';

  @override
  String get classesAppBarTitle => 'Classes';

  @override
  String get noClassRoomsFound => 'No class rooms found';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term.';

  @override
  String subjectCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subjects',
      one: '$count subject',
    );
    return '$_temp0';
  }

  @override
  String get myCourseTitle => 'My Course';

  @override
  String get myCourseSubtitle =>
      'Browse your enrolled classes and open a workspace to see quizzes and results';

  @override
  String courseCountLabel(Object filtered, Object total) {
    return '$filtered of $total subjects';
  }

  @override
  String get filterClassLabel => 'Class';

  @override
  String get filterSubjectLabel => 'Subject';

  @override
  String get filterShiftLabel => 'Shift';

  @override
  String get allClassesFilter => 'All Classes';

  @override
  String get allSubjectsFilter => 'All Subjects';

  @override
  String get allShiftsFilter => 'All Shifts';

  @override
  String get allAcademicYearsFilter => 'All Years';

  @override
  String get searchCoursesHint => 'Subject, class...';

  @override
  String get noEnrolledCoursesTitle => 'No Enrolled Courses Found';

  @override
  String get noEnrolledCoursesSubtitle =>
      'You\'re not enrolled in any subjects for this semester yet.';

  @override
  String get noCoursesMatchFilters => 'No courses match your filters.';

  @override
  String get totalQuizzesBoxLabel => 'Total Quizzes';

  @override
  String percentCompleteLabel(Object percent) {
    return '$percent% complete';
  }

  @override
  String get viewQuizzesAction => 'View Quizzes';

  @override
  String teacherPrefixLabel(Object name) {
    return 'Teacher: $name';
  }

  @override
  String get quizzesTabLabel => 'Quizzes';

  @override
  String get resultsTabLabel => 'Results';

  @override
  String get openNowLabel => 'Open Now';

  @override
  String get upcomingLabel => 'Upcoming';

  @override
  String get noOpenQuizzesForCourse =>
      'No quizzes are open for this course right now.';

  @override
  String lastSubmittedLabel(Object date) {
    return 'Last submitted $date';
  }

  @override
  String attemptsCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts',
      one: '1 attempt',
    );
    return '$_temp0';
  }

  @override
  String scoreOfTotalPercentLabel(Object score, Object total, Object percent) {
    return '$score / $total ($percent%)';
  }

  @override
  String get quizzesScreenTitle => 'Quiz';

  @override
  String get quizzesScreenSubtitle => 'All your quizzes across every class';

  @override
  String get searchQuizzesHint => 'Search quiz title...';

  @override
  String get noQuizzesMatchFilters => 'No quizzes match your filters.';

  @override
  String get genericErrorMessage => 'Something went wrong. Please try again.';

  @override
  String couldNotReachServer(Object url) {
    return 'Could not reach the server at $url';
  }

  @override
  String get sessionExpiredMessage => 'Session expired. Please log in again.';

  @override
  String requestFailedWithCode(Object statusCode) {
    return 'Request failed ($statusCode)';
  }

  @override
  String get adminNotSupportedMessage =>
      'Admin accounts aren\'t supported in this app — please use the web dashboard.';

  @override
  String unrecognizedRoleMessage(Object role) {
    return 'Unrecognized account role \"$role\".';
  }

  @override
  String get assessmentNotFoundMessage => 'Assessment not found.';
}
