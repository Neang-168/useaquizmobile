import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import '../l10n/generated/app_localizations.dart';
import 'classrooms_screen.dart';
import 'subjects_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'teacher_results_screen.dart';
import 'teacher_profile_screen.dart';
import 'class_question_breakdown_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _navIndex = 0;

  List<BottomNavItem> _navItems(AppLocalizations l) => [
        (icon: Icons.dashboard_rounded, label: l.navDashboard),
        (icon: Icons.fact_check_rounded, label: l.navResults),
        (icon: Icons.meeting_room_rounded, label: l.navClass),
        (icon: Icons.person_rounded, label: l.navProfile),
      ];

  void _openClassRoom(ClassRoom c) {
    Navigator.of(context).push(
      fadeRoute(
        SubjectsScreen(
          classRoomId: c.id,
          classRoomName: c.name,
          onSubjectTap: (s) => Navigator.of(context).push(
            fadeRoute(
              ClassQuestionBreakdownScreen(
                subjectId: s.id,
                subjectName: s.name,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const TeacherDashboardScreen(embedded: true),
      const TeacherResultsScreen(embedded: true),
      ClassRoomsScreen(embedded: true, onClassRoomTap: _openClassRoom),
      const TeacherProfileScreen(embedded: true),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_navIndex]),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        items: _navItems(AppLocalizations.of(context)),
      ),
    );
  }
}
