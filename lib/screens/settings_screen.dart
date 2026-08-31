import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/app_repository.dart';
import '../widgets/common_widgets.dart';
import '../l10n/generated/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsOn = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _notificationsOn = prefs.getBool('pref_notifications') ?? true);
  }

  Future<void> _savePreferences() async {
    try {
      await AppRepository.instance.updatePreferences(notifications: _notificationsOn, darkMode: ThemeController.isDark.value);
    } catch (_) {
      // best-effort; preferences already reflected in local UI state
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle), leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(l.preferencesTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Container(
              decoration: softCardDecoration(),
              child: Column(
                children: [
                  SettingsSwitchTile(
                    icon: Icons.notifications_outlined,
                    label: l.notificationsLabel,
                    value: _notificationsOn,
                    onChanged: (v) {
                      setState(() => _notificationsOn = v);
                      _savePreferences();
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  ValueListenableBuilder<bool>(
                    valueListenable: ThemeController.isDark,
                    builder: (context, isDark, _) => SettingsSwitchTile(
                      icon: Icons.dark_mode_outlined,
                      label: l.darkModeLabel,
                      value: isDark,
                      onChanged: (v) {
                        ThemeController.setDark(v);
                        _savePreferences();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(l.languageLabel, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Container(
              decoration: softCardDecoration(),
              child: ValueListenableBuilder<Locale>(
                valueListenable: LocaleController.locale,
                builder: (context, locale, _) => Column(
                  children: [
                    _LanguageOptionTile(
                      label: l.languageEnglish,
                      selected: locale.languageCode == 'en',
                      onTap: () => LocaleController.setLocale(const Locale('en')),
                    ),
                    const Divider(height: 1, indent: 60),
                    _LanguageOptionTile(
                      label: l.languageKhmer,
                      selected: locale.languageCode == 'km',
                      onTap: () => LocaleController.setLocale(const Locale('km')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(l.aboutTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ProfileDetailsCard(rows: [
              (icon: Icons.school_outlined, label: l.appNameLabel, value: l.appTitle),
              (icon: Icons.apartment_outlined, label: l.universityLabel, value: l.splashUniversityName),
              (icon: Icons.info_outline_rounded, label: l.versionLabel, value: '1.0.0'),
            ]),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LanguageOptionTile({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconBadge(icon: Icons.language_rounded, color: AppColors.primary, size: 38),
      title: Text(label, style: Theme.of(context).textTheme.titleMedium),
      trailing: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: selected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, key: ValueKey('checked'))
            : Icon(Icons.circle_outlined, color: AppColors.textMuted, key: const ValueKey('unchecked')),
      ),
      onTap: onTap,
    );
  }
}
