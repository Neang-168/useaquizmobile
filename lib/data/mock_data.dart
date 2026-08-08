import 'package:flutter/material.dart';
import '../models/models.dart';

class MockData {
  MockData._();

  static const studentName = 'Sochea Ratanak';
  static const studentId = 'ITU2023-0142';
  static const faculty = 'Faculty of Information Technology';
  static const major = 'Software Engineering';
  static const academicYear = 'Year 3, Semester 1';

  static final List<Subject> subjects = [
    const Subject(
      id: 'sub-android',
      name: 'Android Mobile App Development',
      code: 'IT-402',
      semester: 'Semester 5',
      icon: Icons.phone_android_rounded,
      color: Color(0xFF2563EB),
      totalAssessments: 4,
      completed: 1,
    ),
    const Subject(
      id: 'sub-database',
      name: 'Database Systems',
      code: 'IT-305',
      semester: 'Semester 5',
      icon: Icons.storage_rounded,
      color: Color(0xFF10B981),
      totalAssessments: 3,
      completed: 3,
    ),
    const Subject(
      id: 'sub-web',
      name: 'Web Development',
      code: 'IT-310',
      semester: 'Semester 5',
      icon: Icons.language_rounded,
      color: Color(0xFFF59E0B),
      totalAssessments: 3,
      completed: 0,
    ),
    const Subject(
      id: 'sub-swe',
      name: 'Software Engineering',
      code: 'IT-330',
      semester: 'Semester 5',
      icon: Icons.integration_instructions_rounded,
      color: Color(0xFF7C3AED),
      totalAssessments: 2,
      completed: 1,
    ),
    const Subject(
      id: 'sub-network',
      name: 'Networking',
      code: 'IT-350',
      semester: 'Semester 5',
      icon: Icons.hub_rounded,
      color: Color(0xFFEF4444),
      totalAssessments: 2,
      completed: 0,
    ),
  ];

  static final Assessment androidAssessment = Assessment(
    id: 'assess-android-101',
    subject: 'Android Mobile App Development',
    lecturer: 'Dr. Sok Pisey',
    totalQuestions: 5,
    timeLimitMinutes: 15,
    availableDate: 'Jul 21, 2026',
    dueDate: 'Jul 24, 2026, 11:59 PM',
    color: const Color(0xFF2563EB),
    icon: Icons.phone_android_rounded,
    objectives: const [
      'Recall foundational Android development concepts',
      'Identify core building blocks of an Android app',
      'Assess familiarity with Kotlin and XML basics',
    ],
    questions: const [
      Question(
        text: 'What is Android Studio?',
        options: [
          'A mobile operating system',
          'The official IDE for Android app development',
          'A cloud hosting service',
          'A database management tool',
        ],
        correctIndex: 1,
        explanation:
            'Android Studio is the official Integrated Development Environment (IDE) for Android app development, built on JetBrains IntelliJ IDEA.',
      ),
      Question(
        text: 'Which language is primarily used for modern Android development?',
        options: ['Swift', 'Kotlin', 'PHP', 'Ruby'],
        correctIndex: 1,
        explanation:
            'Kotlin is Google\'s preferred and officially recommended language for Android development since 2019.',
      ),
      Question(
        text: 'What is an Activity in Android?',
        options: [
          'A background network request',
          'A single, focused screen the user interacts with',
          'A type of database query',
          'A style sheet for layouts',
        ],
        correctIndex: 1,
        explanation: 'An Activity represents a single screen with a user interface in an Android app.',
      ),
      Question(
        text: 'What is XML primarily used for in Android?',
        options: [
          'Writing business logic',
          'Defining UI layouts and resources',
          'Managing app permissions only',
          'Compiling native code',
        ],
        correctIndex: 1,
        explanation: 'XML is commonly used to declare UI layouts, strings, colors, and other resources.',
      ),
      Question(
        text: 'What is Gradle used for in Android projects?',
        options: [
          'Designing app icons',
          'Automating builds and managing dependencies',
          'Handling push notifications',
          'Rendering XML layouts at runtime',
        ],
        correctIndex: 1,
        explanation: 'Gradle is the build automation tool used to compile, package, and manage dependencies for Android projects.',
      ),
    ],
  );

  static final List<HistoryItem> history = [
    HistoryItem(subject: 'Database Systems', date: 'Jul 10, 2026', score: 92, status: 'Excellent', color: const Color(0xFF10B981)),
    HistoryItem(subject: 'Database Systems', date: 'Jun 28, 2026', score: 85, status: 'Good', color: const Color(0xFF3B82F6)),
    HistoryItem(subject: 'Software Engineering', date: 'Jun 20, 2026', score: 68, status: 'Average', color: const Color(0xFFF59E0B)),
    HistoryItem(subject: 'Database Systems', date: 'Jun 12, 2026', score: 74, status: 'Good', color: const Color(0xFF3B82F6)),
  ];

  static final List<AppNotification> notifications = [
    AppNotification(
      title: 'New Assessment Assigned',
      subtitle: 'Android Mobile App Development pre-study quiz is now available.',
      time: '2h ago',
      icon: Icons.assignment_rounded,
      color: const Color(0xFF2563EB),
      unread: true,
    ),
    AppNotification(
      title: 'Assessment Deadline Reminder',
      subtitle: 'Web Development pre-study quiz is due in 2 days.',
      time: '5h ago',
      icon: Icons.alarm_rounded,
      color: const Color(0xFFF59E0B),
      unread: true,
    ),
    AppNotification(
      title: 'Assessment Result Available',
      subtitle: 'Your Database Systems result has been released.',
      time: 'Yesterday',
      icon: Icons.emoji_events_rounded,
      color: const Color(0xFF10B981),
      unread: false,
    ),
    AppNotification(
      title: 'Lecturer Announcement',
      subtitle: 'Dr. Sok Pisey posted a note about the first class session.',
      time: '2 days ago',
      icon: Icons.campaign_rounded,
      color: const Color(0xFF7C3AED),
      unread: false,
    ),
  ];
}
