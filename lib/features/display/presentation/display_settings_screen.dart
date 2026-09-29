import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/sound/sound_service.dart';
import '../../../core/theme/alamiyah_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/display_prefs.dart';

class DisplaySettingsScreen extends ConsumerWidget {
  const DisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(displayPrefsProvider);
    final colors = context.alamiyahColors;
    final motion = AppMotion.of(context, AppMotion.screen);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Display',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            color: colors.brandPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          Text(
            'Reading atmosphere',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.brandSecondary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          const _PreviewCard(),
          const SizedBox(height: 28),
          _SectionLabel(label: 'Theme', colors: colors),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: [
              for (final id in AppThemeId.values)
                _ThemeChoice(
                  id: id,
                  selected: prefs.theme == id,
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    await ref.read(displayPrefsProvider.notifier).setTheme(id);
                    await ref.read(soundServiceProvider).settle();
                  },
                ),
            ],
          ),
          const SizedBox(height: 28),
          _SectionLabel(label: 'Text size', colors: colors),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final label in DisplayPrefs.fontLabels)
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.brandSecondary,
                  ),
                ),
            ],
          ),
          Slider(
            min: 0,
            max: 3,
            divisions: 3,
            value: prefs.fontStopIndex.toDouble(),
            onChanged: (v) async {
              final scale = DisplayPrefs.fontStops[v.round()];
              if (scale == prefs.fontScale) return;
              HapticFeedback.selectionClick();
              await ref.read(displayPrefsProvider.notifier).setFontScale(scale);
              await ref.read(soundServiceProvider).tick();
            },
          ),
          const SizedBox(height: 12),
          _SectionLabel(label: 'Accent', colors: colors),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final id in AccentId.values)
                _AccentDot(
                  id: id,
                  selected: prefs.accent == id,
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    await ref.read(displayPrefsProvider.notifier).setAccent(id);
                    await ref.read(soundServiceProvider).tick();
                  },
                ),
            ],
          ),
          const SizedBox(height: 28),
          _SectionLabel(label: 'Arabic typeface', colors: colors),
          const SizedBox(height: 12),
          for (final id in ArabicFontId.values) ...[
            _FontChoice(
              id: id,
              selected: prefs.arabicFont == id,
              onTap: () async {
                HapticFeedback.selectionClick();
                await ref
                    .read(displayPrefsProvider.notifier)
                    .setArabicFont(id);
                await ref.read(soundServiceProvider).tick();
              },
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          _ToggleCard(
            title: 'Reduce motion',
            subtitle: 'Shorter, calmer transitions',
            value: prefs.reduceMotion,
            duration: motion,
            onChanged: (v) async {
              HapticFeedback.selectionClick();
              await ref
                  .read(displayPrefsProvider.notifier)
                  .setReduceMotion(v);
              await ref.read(soundServiceProvider).tick();
            },
          ),
          const SizedBox(height: 10),
          _ToggleCard(
            title: 'Sound effects',
            subtitle: 'Quiet ticks and chimes',
            value: prefs.soundEffects,
            duration: motion,
            onChanged: (v) async {
              HapticFeedback.selectionClick();
              await ref
                  .read(displayPrefsProvider.notifier)
                  .setSoundEffects(v);
              if (v) await ref.read(soundServiceProvider).tick();
            },
          ),
          const SizedBox(height: 18),
          _SectionLabel(label: 'Notification chime', colors: colors),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in ChimeId.values)
                ChoiceChip(
                  label: Text(id.label),
                  selected: prefs.chime == id,
                  onSelected: (_) async {
                    HapticFeedback.selectionClick();
                    await ref.read(displayPrefsProvider.notifier).setChime(id);
                    await ref.read(soundServiceProvider).previewChime(id);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.colors});

  final String label;
  final AlamiyahColors colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.brandPrimary,
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.theme),
      curve: AppMotion.curve,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colors.softShadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: colors.accentGold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.brandSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
              textDirection: TextDirection.rtl,
              style: AppTheme.arabicStyle(context, fontSize: 26),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Alhamdu lillahi rabbil-alamin',
            style: GoogleFonts.dmSans(
              fontSize: context.contentSize(14),
              fontStyle: FontStyle.italic,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'All praise is for Allah, Lord of the worlds.',
            style: GoogleFonts.dmSans(
              fontSize: context.contentSize(15),
              height: 1.45,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.id,
    required this.selected,
    required this.onTap,
  });

  final AppThemeId id;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = id.palette;
    return Material(
      color: palette.cardBackground,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.micro),
          curve: AppMotion.curve,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? palette.accentGold : palette.chipBackground,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Swatch(color: palette.brandPrimary),
                  const SizedBox(width: 6),
                  _Swatch(color: palette.brandSecondary),
                  const SizedBox(width: 6),
                  _Swatch(color: palette.surfaceElevated),
                  const Spacer(),
                  if (selected)
                    Icon(Icons.check_circle_rounded,
                        size: 18, color: palette.accentGold),
                ],
              ),
              const Spacer(),
              Text(
                id.label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: palette.brandPrimary,
                ),
              ),
              Text(
                id.subtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: palette.brandSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
    );
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({
    required this.id,
    required this.selected,
    required this.onTap,
  });

  final AccentId id;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.micro),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: id.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? context.alamiyahColors.brandPrimary
                    : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: id.color.withValues(alpha: 0.35),
                  blurRadius: selected ? 10 : 0,
                ),
              ],
            ),
            child: selected
                ? Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: id.color.computeLuminance() > 0.45
                        ? const Color(0xFF1E3D32)
                        : Colors.white,
                  )
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            id.label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: context.alamiyahColors.brandSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FontChoice extends StatelessWidget {
  const _FontChoice({
    required this.id,
    required this.selected,
    required this.onTap,
  });

  final ArabicFontId id;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final sample = switch (id) {
      ArabicFontId.naskh => GoogleFonts.notoNaskhArabic(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colors.arabicEmphasis,
        ),
      ArabicFontId.amiri => GoogleFonts.amiri(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colors.arabicEmphasis,
        ),
      ArabicFontId.scheherazade => GoogleFonts.scheherazadeNew(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colors.arabicEmphasis,
        ),
    };

    return Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.micro),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colors.accentGold : colors.chipBackground,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      id.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.brandPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textDirection: TextDirection.rtl,
                      style: sample,
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: colors.accentGold),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.duration,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return AnimatedContainer(
      duration: duration,
      curve: AppMotion.curve,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: colors.brandPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: colors.brandSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
