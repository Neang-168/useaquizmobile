import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

typedef BottomNavItem = ({IconData icon, String label});

/// Bottom navigation used across Home, Subjects, Assessments, History, Profile
/// (and, with a custom [items] list, the teacher layout).
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;
  const AppBottomNav({super.key, required this.currentIndex, required this.onTap, this.items = _defaultItems});

  static const _defaultItems = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.menu_book_rounded, label: 'Subjects'),
    (icon: Icons.fact_check_rounded, label: 'Assessments'),
    (icon: Icons.history_rounded, label: 'History'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final active = i == currentIndex;
            final item = items[i];
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: active ? AppColors.primary : AppColors.textMuted, size: 24),
                    const SizedBox(height: 3),
                    Text(item.label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? AppColors.primary : AppColors.textMuted,
                        )),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13.5)),
          ),
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const StatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11.5)),
    );
  }
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconBadge({super.key, required this.icon, required this.color, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Simple skeleton loading block, used for empty/loading states.
class SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;
  const SkeletonBox({super.key, required this.height, this.width, this.radius = AppRadius.sm});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(color: AppColors.skeleton, borderRadius: BorderRadius.circular(radius)),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Icon(icon, size: 38, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Shown when the repository fell back to mock data because the REST API
/// couldn't be reached, so the demo experience stays honest about its state.
class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Showing demo data — the API server isn\'t reachable right now.',
                style: TextStyle(fontSize: 11.5, color: const Color(0xFF92400E).withValues(alpha: 0.9), fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

/// Full-bleed gradient hero used atop the student/teacher profile screens:
/// a large avatar (initials), an edit badge overlapping its bottom-right
/// corner, the person's name, and a subtitle (their ID).
class ProfileHeroHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final VoidCallback onEdit;
  const ProfileHeroHeader({super.key, required this.name, required this.subtitle, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(RegExp(r'\s+')).map((w) => w[0]).take(2).join().toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 38),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22), bottomRight: Radius.circular(22)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2.5),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child: Text(initials,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Tooltip(
                    message: 'Edit profile',
                    child: Material(
                      color: AppColors.primaryDark,
                      shape: CircleBorder(side: BorderSide(color: AppColors.surface, width: 2)),
                      elevation: 2,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onEdit,
                        child: const SizedBox(
                          width: 30,
                          height: 30,
                          child: Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

typedef ProfileDetailRow = ({IconData icon, String label, String value});

/// Icon/label/value rows (e.g. Email, Faculty, Major) in a `softCardDecoration`
/// card, used below [ProfileHeroHeader] on the profile screens.
class ProfileDetailsCard extends StatelessWidget {
  final List<ProfileDetailRow> rows;
  const ProfileDetailsCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: softCardDecoration(),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 24),
            _row(context, rows[i]),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, ProfileDetailRow row) {
    return Row(
      children: [
        Icon(row.icon, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(row.label, style: Theme.of(context).textTheme.bodyMedium)),
        Flexible(child: Text(row.value, textAlign: TextAlign.end, style: Theme.of(context).textTheme.titleMedium)),
      ],
    );
  }
}

/// A labeled switch row for the profile "Preferences" card.
class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const SettingsSwitchTile(
      {super.key, required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          IconBadge(icon: icon, color: AppColors.primary, size: 38),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
          Switch(value: value, activeThumbColor: AppColors.primary, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// A tappable settings row for the profile "Preferences" card. Currently
/// used for placeholder entries (Settings, Help & Support) with no
/// destination screen yet, so [onTap] is a no-op.
class SettingsNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const SettingsNavTile({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconBadge(icon: icon, color: AppColors.primary, size: 38),
      title: Text(label, style: Theme.of(context).textTheme.titleMedium),
      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: () {},
    );
  }
}

/// Red outlined "Log Out" button with a loading-spinner state, used on the
/// student and teacher profile screens.
class LogoutButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  const LogoutButton({super.key, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger))
          : const Icon(Icons.logout_rounded, size: 18),
      label: Text(loading ? 'Logging out...' : 'Log Out'),
    );
  }
}

PageRoute<T> fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: const Duration(milliseconds: 260),
  );
}
