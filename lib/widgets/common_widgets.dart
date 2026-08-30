import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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

/// Shown in place of a screen's content when its data failed to load —
/// a network error, an expired session that isn't a clean 401, etc.
/// [message] should be the caught [ApiException]'s human-readable text.
class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorStateView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: const Icon(Icons.cloud_off_rounded, size: 38, color: AppColors.danger),
          ),
          const SizedBox(height: 16),
          Text('Couldn\'t load this', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Full-bleed navy header (USEA crest, org name, tappable initials avatar)
/// used atop the student/teacher Profile screens. Pair with [GaugeStatCard],
/// which overlaps its bottom edge.
class BrandHeaderBar extends StatelessWidget {
  final String initials;
  final VoidCallback? onAvatarTap;
  const BrandHeaderBar({super.key, required this.initials, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        width: double.infinity,
        color: AppColors.primary,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.asset('assets/usealogo.jpg', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'UNIVERSITY OF\nSOUTH-EAST ASIA',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: 0.3),
                  ),
                ),
                GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1.5),
                    ),
                    child: Center(
                      child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// White card with a circular percent gauge and a two-line color legend,
/// floating over the bottom edge of a [BrandHeaderBar]. The overlap is done
/// with [Transform.translate] — it only shifts where the card is *painted*,
/// leaving its layout box (and the space siblings see) untouched, so it
/// can't hit the non-negative-inset assertions that both [Container.margin]
/// and [Padding] enforce. The gap that leaves behind is intentional: it
/// becomes the breathing room before the next section, so callers shouldn't
/// add extra spacing directly after this widget.
class GaugeStatCard extends StatelessWidget {
  final String title;
  final double percent;
  final String centerLabel;
  final String doneLabel;
  final String remainingLabel;
  const GaugeStatCard({
    super.key,
    required this.title,
    required this.percent,
    required this.centerLabel,
    required this.doneLabel,
    required this.remainingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Transform.translate(
        // Kept smaller than softCardDecoration's corner radius (AppRadius.lg
        // = 20) so the card's rounded top stays visible below the header
        // instead of being pulled entirely behind it, which reads as a
        // flush square seam instead of a floating card.
        offset: const Offset(0, -16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: softCardDecoration(),
          child: Row(
            children: [
              CircularPercentIndicator(
                radius: 50,
                lineWidth: 11,
                percent: percent.clamp(0, 1),
                backgroundColor: AppColors.skeleton,
                progressColor: AppColors.primary,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(centerLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _LegendDot(color: AppColors.primary, label: doneLabel),
                    const SizedBox(height: 8),
                    _LegendDot(color: AppColors.skeleton, label: remainingLabel),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}

/// One tappable shortcut card (icon + label) for a [ShortcutGrid].
class ShortcutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const ShortcutTile({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: softCardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBadge(icon: icon, color: AppColors.primary, size: 46),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

/// Lays [tiles] out two per row, each row's height set by its own content
/// (not a fixed aspect ratio), so a long label or a larger text-scale
/// setting can't overflow the card.
class ShortcutGrid extends StatelessWidget {
  final List<ShortcutTile> tiles;
  const ShortcutGrid({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += 2) {
      final hasSecond = i + 1 < tiles.length;
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 12));
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: tiles[i]),
            const SizedBox(width: 12),
            Expanded(child: hasSecond ? tiles[i + 1] : const SizedBox()),
          ],
        ),
      ));
    }
    return Column(children: rows);
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
    // The label gets a fixed column (not Expanded) so a short word like
    // "Email" doesn't claim half the row and squeeze a long, unbreakable
    // value (e.g. an email address) into an awkward mid-word wrap.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(row.icon, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 12),
        SizedBox(
          width: 112,
          child: Text(row.label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(row.value, textAlign: TextAlign.end, style: Theme.of(context).textTheme.titleMedium)),
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
