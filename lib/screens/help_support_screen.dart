import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../l10n/generated/app_localizations.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _supportEmail = 'support@usea.edu.kh';
  static const _supportPhone = '+855 12 345 678';

  List<({String question, String answer})> _faqs(AppLocalizations l) => [
        (question: l.faqQ1, answer: l.faqA1),
        (question: l.faqQ2, answer: l.faqA2),
        (question: l.faqQ3, answer: l.faqA3),
        (question: l.faqQ4, answer: l.faqA4),
        (question: l.faqQ5, answer: l.faqA5),
      ];

  Future<void> _launch(BuildContext context, Uri uri, String appName) async {
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).couldntOpenApp(appName)), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final faqs = _faqs(l);
    return Scaffold(
      appBar: AppBar(title: Text(l.helpSupportTitle), leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(l.faqTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Container(
              decoration: softCardDecoration(),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: Column(
                  children: [
                    for (var i = 0; i < faqs.length; i++) ...[
                      if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                      ExpansionTile(
                        title: Text(faqs[i].question, style: Theme.of(context).textTheme.titleMedium),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        expandedAlignment: Alignment.centerLeft,
                        children: [
                          Text(faqs[i].answer, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(l.contactUsTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Container(
              decoration: softCardDecoration(),
              child: Column(
                children: [
                  ListTile(
                    leading: const IconBadge(icon: Icons.email_outlined, color: AppColors.primary, size: 38),
                    title: Text(l.emailLabel, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(_supportEmail, style: Theme.of(context).textTheme.bodyMedium),
                    trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    onTap: () => _launch(context, Uri(scheme: 'mailto', path: _supportEmail), l.emailLabel),
                  ),
                  const Divider(height: 1, indent: 60),
                  ListTile(
                    leading: const IconBadge(icon: Icons.call_outlined, color: AppColors.primary, size: 38),
                    title: Text(l.phoneLabel, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(_supportPhone, style: Theme.of(context).textTheme.bodyMedium),
                    trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    onTap: () => _launch(context, Uri(scheme: 'tel', path: _supportPhone.replaceAll(' ', '')), l.phoneLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
