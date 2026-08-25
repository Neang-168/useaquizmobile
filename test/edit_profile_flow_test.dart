import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:useaquizmobile/screens/profile_screen.dart';
import 'package:useaquizmobile/screens/teacher_profile_screen.dart';
import 'package:useaquizmobile/theme/app_theme.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // The default test HttpOverrides intercepts all requests and returns a
    // fake 200/400, which prevents the repository from ever seeing a real
    // connectivity failure and falling back to demo data. Restore real
    // dart:io networking so the (unreachable in this environment) API call
    // genuinely fails and exercises the offline/demo path under test.
    HttpOverrides.global = null;
  });

  testWidgets('student profile: edit name/email and dark mode toggle work', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(find.text('Sochea Ratanak'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Edit Profile'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Updated Student');
    await tester.enterText(find.byType(TextFormField).last, 'updated.student@usea.edu.kh');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(find.text('Edit Profile'), findsNothing);
    expect(find.text('Updated Student'), findsOneWidget);

    expect(ThemeController.isDark.value, isFalse);
    await tester.scrollUntilVisible(find.text('Dark Mode'), 300, scrollable: find.byType(Scrollable).first);
    final darkModeRow = find.ancestor(of: find.text('Dark Mode'), matching: find.byType(Row));
    await tester.tap(find.descendant(of: darkModeRow, matching: find.byType(Switch)));
    await tester.pump();
    // Toggling dark mode fires a best-effort preferences PATCH in the
    // background; advance past its network timeout so no Timer is left
    // pending when the test tears down the widget tree.
    await tester.pump(const Duration(seconds: 9));
    expect(ThemeController.isDark.value, isTrue);
    ThemeController.setDark(false);
  });

  testWidgets('teacher profile: edit name/email and dark mode toggle work', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TeacherProfileScreen()));
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(find.text('Dr. Meas Sophea'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Edit Profile'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Updated Teacher');
    await tester.enterText(find.byType(TextFormField).last, 'updated.teacher@usea.edu.kh');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(find.text('Edit Profile'), findsNothing);
    expect(find.text('Updated Teacher'), findsOneWidget);

    expect(ThemeController.isDark.value, isFalse);
    await tester.scrollUntilVisible(find.text('Dark Mode'), 300, scrollable: find.byType(Scrollable).first);
    final darkModeRow = find.ancestor(of: find.text('Dark Mode'), matching: find.byType(Row));
    await tester.tap(find.descendant(of: darkModeRow, matching: find.byType(Switch)));
    await tester.pump();
    // Toggling dark mode fires a best-effort preferences PATCH in the
    // background; advance past its network timeout so no Timer is left
    // pending when the test tears down the widget tree.
    await tester.pump(const Duration(seconds: 9));
    expect(ThemeController.isDark.value, isTrue);
    ThemeController.setDark(false);
  });
}
