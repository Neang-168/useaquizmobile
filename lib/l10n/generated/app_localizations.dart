import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-Study IT Knowledge Assessment'**
  String get appTitle;

  /// No description provided for @universityName.
  ///
  /// In en, this message translates to:
  /// **'UNIVERSITY OF\nSOUTH-EAST ASIA'**
  String get universityName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSubjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get navSubjects;

  /// No description provided for @navAssessments.
  ///
  /// In en, this message translates to:
  /// **'Assessments'**
  String get navAssessments;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get navResults;

  /// No description provided for @navClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get navClass;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @couldntLoadThis.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this'**
  String get couldntLoadThis;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get loggingOut;

  /// No description provided for @splashUniversityName.
  ///
  /// In en, this message translates to:
  /// **'University of Southeast Asia'**
  String get splashUniversityName;

  /// No description provided for @splashAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-Study IT\nKnowledge Assessment'**
  String get splashAppTitle;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Know where you stand before class begins'**
  String get splashTagline;

  /// No description provided for @loginUniversityName.
  ///
  /// In en, this message translates to:
  /// **'UNIVERSITY OF SOUTH-EAST ASIA'**
  String get loginUniversityName;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Sign in to continue your pre-study assessments.'**
  String get loginWelcome;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginStudentId.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get loginStudentId;

  /// No description provided for @loginStudentIdHint.
  ///
  /// In en, this message translates to:
  /// **'ITU2023-0142'**
  String get loginStudentIdHint;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// No description provided for @loginRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get loginRememberMe;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @preferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesTitle;

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;

  /// No description provided for @darkModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @appNameLabel.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get appNameLabel;

  /// No description provided for @universityLabel.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get universityLabel;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageKhmer.
  ///
  /// In en, this message translates to:
  /// **'ខ្មែរ'**
  String get languageKhmer;

  /// No description provided for @settingsNav.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsNav;

  /// No description provided for @helpSupportNav.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupportNav;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupportTitle;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @contactUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @faqQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I take an assessment?'**
  String get faqQ1;

  /// No description provided for @faqA1.
  ///
  /// In en, this message translates to:
  /// **'Open the Assessments tab, pick an upcoming assessment, and tap Start. Answer each question and submit before the due date shown on the assessment card.'**
  String get faqA1;

  /// No description provided for @faqQ2.
  ///
  /// In en, this message translates to:
  /// **'Where can I see my results?'**
  String get faqQ2;

  /// No description provided for @faqA2.
  ///
  /// In en, this message translates to:
  /// **'Your score appears right after you submit an assessment, and every past attempt is saved under the History tab (or the History shortcut on your Profile).'**
  String get faqA2;

  /// No description provided for @faqQ3.
  ///
  /// In en, this message translates to:
  /// **'How do I check my class schedule?'**
  String get faqQ3;

  /// No description provided for @faqA3.
  ///
  /// In en, this message translates to:
  /// **'Tap the Schedule shortcut on your Profile screen to see upcoming classes and assessment due dates in one place.'**
  String get faqA3;

  /// No description provided for @faqQ4.
  ///
  /// In en, this message translates to:
  /// **'I forgot my password. What do I do?'**
  String get faqQ4;

  /// No description provided for @faqA4.
  ///
  /// In en, this message translates to:
  /// **'Contact your class teacher or the university IT office to have your password reset — accounts are managed centrally and can\'t be reset from within the app.'**
  String get faqA4;

  /// No description provided for @faqQ5.
  ///
  /// In en, this message translates to:
  /// **'Why aren\'t I receiving notifications?'**
  String get faqQ5;

  /// No description provided for @faqA5.
  ///
  /// In en, this message translates to:
  /// **'Check that Notifications is turned on in Settings, and that notifications are allowed for this app in your device\'s system settings.'**
  String get faqA5;

  /// No description provided for @couldntOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open {app} app'**
  String couldntOpenApp(Object app);

  /// No description provided for @editProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileLabel;

  /// No description provided for @scheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleLabel;

  /// No description provided for @historyLabel.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyLabel;

  /// No description provided for @resultsLabel.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get resultsLabel;

  /// No description provided for @classesLabel.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classesLabel;

  /// No description provided for @majorLabel.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get majorLabel;

  /// No description provided for @classLabel.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get classLabel;

  /// No description provided for @academicYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Academic Year'**
  String get academicYearLabel;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back 👋'**
  String get welcomeBack;

  /// No description provided for @yourLearningProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Learning Progress'**
  String get yourLearningProgress;

  /// No description provided for @completedOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} completed'**
  String completedOfTotal(Object completed, Object total);

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @noAssessmentsAssignedYet.
  ///
  /// In en, this message translates to:
  /// **'No assessments assigned yet'**
  String get noAssessmentsAssignedYet;

  /// No description provided for @allCaughtUpNothingDue.
  ///
  /// In en, this message translates to:
  /// **'All caught up — nothing due right now'**
  String get allCaughtUpNothingDue;

  /// No description provided for @noProgressYet.
  ///
  /// In en, this message translates to:
  /// **'No progress yet'**
  String get noProgressYet;

  /// No description provided for @noProgressYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your completed and to-do assessments will show up here.'**
  String get noProgressYetSubtitle;

  /// No description provided for @announcementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcementsTitle;

  /// No description provided for @noAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No announcements'**
  String get noAnnouncements;

  /// No description provided for @noAnnouncementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback from your teachers will appear here.'**
  String get noAnnouncementsSubtitle;

  /// No description provided for @upcomingAssessments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Assessments'**
  String get upcomingAssessments;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get allCaughtUp;

  /// No description provided for @noUpcomingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No upcoming pre-study assessments right now.'**
  String get noUpcomingSubtitle;

  /// No description provided for @enrolledSubjects.
  ///
  /// In en, this message translates to:
  /// **'Enrolled Subjects'**
  String get enrolledSubjects;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @subjectsEnrolledCount.
  ///
  /// In en, this message translates to:
  /// **'{count} subjects enrolled'**
  String subjectsEnrolledCount(Object count);

  /// No description provided for @completedAssessments.
  ///
  /// In en, this message translates to:
  /// **'Completed Assessments'**
  String get completedAssessments;

  /// No description provided for @historyAction.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyAction;

  /// No description provided for @noCompletedYet.
  ///
  /// In en, this message translates to:
  /// **'No completed assessments yet'**
  String get noCompletedYet;

  /// No description provided for @noCompletedYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Finished pre-study quizzes will appear here.'**
  String get noCompletedYetSubtitle;

  /// No description provided for @completedChartLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedChartLabel;

  /// No description provided for @todoChartLabel.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get todoChartLabel;

  /// No description provided for @durationQuestionsDue.
  ///
  /// In en, this message translates to:
  /// **'{duration} min · {questions} questions{due}'**
  String durationQuestionsDue(Object duration, Object questions, Object due);

  /// No description provided for @dueSuffix.
  ///
  /// In en, this message translates to:
  /// **' · Due {date}'**
  String dueSuffix(Object date);

  /// No description provided for @excellentLevel.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellentLevel;

  /// No description provided for @goodLevel.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get goodLevel;

  /// No description provided for @averageLevel.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get averageLevel;

  /// No description provided for @beginnerLevel.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginnerLevel;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(Object count);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(Object count);

  /// No description provided for @mySubjects.
  ///
  /// In en, this message translates to:
  /// **'My Subjects'**
  String get mySubjects;

  /// No description provided for @assessmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assessments'**
  String get assessmentsTitle;

  /// No description provided for @subjectsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjectsAppBarTitle;

  /// No description provided for @exploreSubjectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore subjects and their pre-study assessments'**
  String get exploreSubjectsSubtitle;

  /// No description provided for @searchSubjectsHint.
  ///
  /// In en, this message translates to:
  /// **'Search subjects...'**
  String get searchSubjectsHint;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @noSubjectsFound.
  ///
  /// In en, this message translates to:
  /// **'No subjects found'**
  String get noSubjectsFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or filter.'**
  String get tryDifferentSearch;

  /// No description provided for @allQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'All Quiz'**
  String get allQuizTitle;

  /// No description provided for @preStudyQuizzesFor.
  ///
  /// In en, this message translates to:
  /// **'Pre-study quizzes for {subject}'**
  String preStudyQuizzesFor(Object subject);

  /// No description provided for @noQuizzesYet.
  ///
  /// In en, this message translates to:
  /// **'No quizzes yet'**
  String get noQuizzesYet;

  /// No description provided for @noQuizzesYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This subject has no pre-study quizzes yet.'**
  String get noQuizzesYetSubtitle;

  /// No description provided for @questionsDuration.
  ///
  /// In en, this message translates to:
  /// **'{questions} questions · {duration} min{due}'**
  String questionsDuration(Object questions, Object duration, Object due);

  /// No description provided for @assessmentDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assessment Details'**
  String get assessmentDetailsTitle;

  /// No description provided for @preStudyAssessmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Pre-Study Assessment'**
  String get preStudyAssessmentLabel;

  /// No description provided for @totalQuestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Questions'**
  String get totalQuestionsLabel;

  /// No description provided for @totalQuestionsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String totalQuestionsValue(Object count);

  /// No description provided for @timeLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Time Limit'**
  String get timeLimitLabel;

  /// No description provided for @minutesValue.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutesValue(Object count);

  /// No description provided for @totalPointsPassMarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Points / Pass Mark'**
  String get totalPointsPassMarkLabel;

  /// No description provided for @pointsPassMarkValue.
  ///
  /// In en, this message translates to:
  /// **'{points} pts · {passMark}%'**
  String pointsPassMarkValue(Object points, Object passMark);

  /// No description provided for @attemptsLabel.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get attemptsLabel;

  /// No description provided for @attemptsValue.
  ///
  /// In en, this message translates to:
  /// **'{used}/{max} used'**
  String attemptsValue(Object used, Object max);

  /// No description provided for @availableFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Available From'**
  String get availableFromLabel;

  /// No description provided for @anytimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get anytimeLabel;

  /// No description provided for @dueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDateLabel;

  /// No description provided for @noDeadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get noDeadlineLabel;

  /// No description provided for @aboutThisQuiz.
  ///
  /// In en, this message translates to:
  /// **'About This Quiz'**
  String get aboutThisQuiz;

  /// No description provided for @instructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsTitle;

  /// No description provided for @honestyNotice.
  ///
  /// In en, this message translates to:
  /// **'This assessment measures your prior knowledge. It will not affect your final grade — answer honestly.'**
  String get honestyNotice;

  /// No description provided for @attemptsUsedUp.
  ///
  /// In en, this message translates to:
  /// **'Attempts Used Up'**
  String get attemptsUsedUp;

  /// No description provided for @assessmentClosed.
  ///
  /// In en, this message translates to:
  /// **'Assessment Closed'**
  String get assessmentClosed;

  /// No description provided for @assessmentNotYetAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Yet Available'**
  String get assessmentNotYetAvailable;

  /// No description provided for @startAssessment.
  ///
  /// In en, this message translates to:
  /// **'Start Assessment'**
  String get startAssessment;

  /// No description provided for @instructionsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsAppBarTitle;

  /// No description provided for @readCarefullySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read the instructions carefully before you begin'**
  String get readCarefullySubtitle;

  /// No description provided for @beforeYouStart.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get beforeYouStart;

  /// No description provided for @ruleTimer.
  ///
  /// In en, this message translates to:
  /// **'You have {minutes} minutes to complete {questions} questions.'**
  String ruleTimer(Object minutes, Object questions);

  /// No description provided for @ruleNoPause.
  ///
  /// In en, this message translates to:
  /// **'The timer cannot be paused once the assessment starts.'**
  String get ruleNoPause;

  /// No description provided for @ruleFlag.
  ///
  /// In en, this message translates to:
  /// **'You may flag questions and revisit them before submitting.'**
  String get ruleFlag;

  /// No description provided for @ruleNoPassingScore.
  ///
  /// In en, this message translates to:
  /// **'A passing score is not required — this is a diagnostic quiz.'**
  String get ruleNoPassingScore;

  /// No description provided for @ruleHonesty.
  ///
  /// In en, this message translates to:
  /// **'Answer independently. This assessment is covered by the academic honesty policy.'**
  String get ruleHonesty;

  /// No description provided for @honestyWarning.
  ///
  /// In en, this message translates to:
  /// **'By starting, you confirm this work is entirely your own, in line with the university\'s Academic Honesty Policy.'**
  String get honestyWarning;

  /// No description provided for @startNowButton.
  ///
  /// In en, this message translates to:
  /// **'I Understand, Start Now'**
  String get startNowButton;

  /// No description provided for @noQuestionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No questions available'**
  String get noQuestionsAvailable;

  /// No description provided for @noQuestionsAvailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This quiz has no questions to take right now.'**
  String get noQuestionsAvailableSubtitle;

  /// No description provided for @questionOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionOfTotal(Object current, Object total);

  /// No description provided for @flagged.
  ///
  /// In en, this message translates to:
  /// **'Flagged'**
  String get flagged;

  /// No description provided for @flagLabel.
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get flagLabel;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @submitDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit Assessment?'**
  String get submitDialogTitle;

  /// No description provided for @unansweredMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You have 1 unanswered question. You can\'t change your answers after submitting.} other{You have {count} unanswered questions. You can\'t change your answers after submitting.}}'**
  String unansweredMessage(num count);

  /// No description provided for @allAnsweredMessage.
  ///
  /// In en, this message translates to:
  /// **'You have answered all questions. You can\'t change your answers after submitting.'**
  String get allAnsweredMessage;

  /// No description provided for @continueAssessment.
  ///
  /// In en, this message translates to:
  /// **'Continue Assessment'**
  String get continueAssessment;

  /// No description provided for @leaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this assessment?'**
  String get leaveDialogTitle;

  /// No description provided for @leaveDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Your timer keeps running even after you leave. If it runs out before you come back, your answers so far will be submitted automatically.'**
  String get leaveDialogBody;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @leaveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Leave Anyway'**
  String get leaveAnyway;

  /// No description provided for @couldntSubmit.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t submit: {error}'**
  String couldntSubmit(Object error);

  /// No description provided for @assessmentComplete.
  ///
  /// In en, this message translates to:
  /// **'Assessment Complete'**
  String get assessmentComplete;

  /// No description provided for @overallScore.
  ///
  /// In en, this message translates to:
  /// **'Overall Score'**
  String get overallScore;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// No description provided for @passMarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Pass Mark'**
  String get passMarkLabel;

  /// No description provided for @passed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get passed;

  /// No description provided for @notPassed.
  ///
  /// In en, this message translates to:
  /// **'Not Passed'**
  String get notPassed;

  /// No description provided for @reviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'A per-question answer review isn\'t available yet — only your overall score is returned.'**
  String get reviewUnavailable;

  /// No description provided for @viewReview.
  ///
  /// In en, this message translates to:
  /// **'View Review'**
  String get viewReview;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @answerReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Answer Review'**
  String get answerReviewTitle;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @unanswered.
  ///
  /// In en, this message translates to:
  /// **'Unanswered'**
  String get unanswered;

  /// No description provided for @matchingReviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Matching-question review isn\'t shown in this simplified demo view.'**
  String get matchingReviewUnavailable;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get noNotificationsSubtitle;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @yourDetails.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get yourDetails;

  /// No description provided for @facultyNote.
  ///
  /// In en, this message translates to:
  /// **'Faculty, major, and academic year are set by the university and can\'t be changed here.'**
  String get facultyNote;

  /// No description provided for @accountStatusNote.
  ///
  /// In en, this message translates to:
  /// **'Your account status is set by the university and can\'t be changed here.'**
  String get accountStatusNote;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get firstNameHint;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your last name'**
  String get lastNameHint;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@usea.edu.kh'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @couldntSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save changes: {error}'**
  String couldntSaveChanges(Object error);

  /// No description provided for @perQuestionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Per-question breakdown unavailable'**
  String get perQuestionUnavailable;

  /// No description provided for @perQuestionUnavailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The API only returns each student\'s overall score, not their answer to every question, so this view can\'t be built from live data.'**
  String get perQuestionUnavailableSubtitle;

  /// No description provided for @scheduleAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleAppBarTitle;

  /// No description provided for @scheduleSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleSectionTitle;

  /// No description provided for @noDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noDataTitle;

  /// No description provided for @noDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled for this day.'**
  String get noDataSubtitle;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @classesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classesCountLabel;

  /// No description provided for @studentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get studentsLabel;

  /// No description provided for @activeQuizzesLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Quizzes'**
  String get activeQuizzesLabel;

  /// No description provided for @pendingEssaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending Essays'**
  String get pendingEssaysLabel;

  /// No description provided for @averageScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get averageScoreLabel;

  /// No description provided for @classPerformance.
  ///
  /// In en, this message translates to:
  /// **'Class Performance'**
  String get classPerformance;

  /// No description provided for @remainingTo100.
  ///
  /// In en, this message translates to:
  /// **'Remaining to 100%'**
  String get remainingTo100;

  /// No description provided for @submissionRatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Submission Rates'**
  String get submissionRatesTitle;

  /// No description provided for @noRecentQuizzes.
  ///
  /// In en, this message translates to:
  /// **'No recent quizzes'**
  String get noRecentQuizzes;

  /// No description provided for @noRecentQuizzesSubmissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Submission rates will appear here once quizzes are published.'**
  String get noRecentQuizzesSubmissionSubtitle;

  /// No description provided for @recentQuizzesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Quizzes'**
  String get recentQuizzesTitle;

  /// No description provided for @noRecentQuizzesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quizzes you publish will show up here.'**
  String get noRecentQuizzesSubtitle;

  /// No description provided for @needsAttentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get needsAttentionTitle;

  /// No description provided for @rawPointTotalsNote.
  ///
  /// In en, this message translates to:
  /// **'Raw point totals — not percentages'**
  String get rawPointTotalsNote;

  /// No description provided for @noStudentsFlagged.
  ///
  /// In en, this message translates to:
  /// **'No students currently flagged'**
  String get noStudentsFlagged;

  /// No description provided for @noStudentsFlaggedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Students scoring below the pass mark will appear here.'**
  String get noStudentsFlaggedSubtitle;

  /// No description provided for @upcomingQuizzesTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Quizzes'**
  String get upcomingQuizzesTitle;

  /// No description provided for @nothingScheduled.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled'**
  String get nothingScheduled;

  /// No description provided for @nothingScheduledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming quizzes will appear here.'**
  String get nothingScheduledSubtitle;

  /// No description provided for @noScheduleSet.
  ///
  /// In en, this message translates to:
  /// **'No schedule set'**
  String get noScheduleSet;

  /// No description provided for @dueDatePrefix.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueDatePrefix(Object date);

  /// No description provided for @submittedCount.
  ///
  /// In en, this message translates to:
  /// **'{submitted}/{total} submitted'**
  String submittedCount(Object submitted, Object total);

  /// No description provided for @ptsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} pts'**
  String ptsLabel(Object count);

  /// No description provided for @assessmentHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Assessment History'**
  String get assessmentHistoryTitle;

  /// No description provided for @trackHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track all your completed pre-study assessments'**
  String get trackHistorySubtitle;

  /// No description provided for @searchBySubjectHint.
  ///
  /// In en, this message translates to:
  /// **'Search by subject...'**
  String get searchBySubjectHint;

  /// No description provided for @historyAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyAppBarTitle;

  /// No description provided for @noHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No history found'**
  String get noHistoryFound;

  /// No description provided for @noHistoryFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Completed assessments will show up here.'**
  String get noHistoryFoundSubtitle;

  /// No description provided for @allResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'All Results'**
  String get allResultsTitle;

  /// No description provided for @everyStudentResultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every student\'s quiz result across all classes'**
  String get everyStudentResultSubtitle;

  /// No description provided for @searchStudentSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'Search by student or subject...'**
  String get searchStudentSubjectHint;

  /// No description provided for @resultsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get resultsAppBarTitle;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @myClassRoomsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Class Rooms'**
  String get myClassRoomsTitle;

  /// No description provided for @selectClassRoomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a class room to view its subjects'**
  String get selectClassRoomSubtitle;

  /// No description provided for @searchClassRoomsHint.
  ///
  /// In en, this message translates to:
  /// **'Search class rooms...'**
  String get searchClassRoomsHint;

  /// No description provided for @classesAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classesAppBarTitle;

  /// No description provided for @noClassRoomsFound.
  ///
  /// In en, this message translates to:
  /// **'No class rooms found'**
  String get noClassRoomsFound;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get tryDifferentSearchTerm;

  /// No description provided for @subjectCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} subject} other{{count} subjects}}'**
  String subjectCount(num count);

  /// No description provided for @genericErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericErrorMessage;

  /// No description provided for @couldNotReachServer.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server at {url}'**
  String couldNotReachServer(Object url);

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get sessionExpiredMessage;

  /// No description provided for @requestFailedWithCode.
  ///
  /// In en, this message translates to:
  /// **'Request failed ({statusCode})'**
  String requestFailedWithCode(Object statusCode);

  /// No description provided for @adminNotSupportedMessage.
  ///
  /// In en, this message translates to:
  /// **'Admin accounts aren\'t supported in this app — please use the web dashboard.'**
  String get adminNotSupportedMessage;

  /// No description provided for @unrecognizedRoleMessage.
  ///
  /// In en, this message translates to:
  /// **'Unrecognized account role \"{role}\".'**
  String unrecognizedRoleMessage(Object role);

  /// No description provided for @assessmentNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Assessment not found.'**
  String get assessmentNotFoundMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
