import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/motion/app_motion.dart';
import '../../core/sound/sound_service.dart';
import '../../core/theme/alamiyah_colors.dart';

class AnimatedFilterChip extends StatelessWidget {
  const AnimatedFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final selectedBg = colors.brandPrimary;
    final selectedFg = selectedBg.computeLuminance() > 0.45
        ? colors.onAccent
        : const Color(0xFFF7F4EE);
    final idleBg = colors.cardBackground;
    final idleFg = colors.brandPrimary;

    return AnimatedScale(
      scale: selected ? 1.04 : 1,
      duration: AppMotion.of(context, AppMotion.micro),
      curve: AppMotion.curve,
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? selectedFg : idleFg,
          ),
        ),
        selected: selected,
        showCheckmark: false,
        backgroundColor: idleBg,
        selectedColor: selectedBg,
        disabledColor: idleBg,
        color: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return selectedBg;
          return idleBg;
        }),
        labelStyle: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? selectedFg : idleFg,
        ),
        side: BorderSide(
          color: selected
              ? selectedBg
              : colors.brandPrimary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onSelected: (value) {
          HapticFeedback.selectionClick();
          SoundService.instance?.tick();
          onSelected(value);
        },
      ),
    );
  }
}
