import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/motion/app_motion.dart';
import '../../core/sound/sound_service.dart';
import '../../core/theme/alamiyah_colors.dart';

class BookmarkBounceButton extends StatefulWidget {
  const BookmarkBounceButton({
    super.key,
    required this.bookmarked,
    required this.onPressed,
  });

  final bool bookmarked;
  final VoidCallback onPressed;

  @override
  State<BookmarkBounceButton> createState() => _BookmarkBounceButtonState();
}

class _BookmarkBounceButtonState extends State<BookmarkBounceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: AppMotion.micro,
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.28), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.28, end: 1), weight: 60),
  ]).animate(CurvedAnimation(parent: _ctrl, curve: AppMotion.curve));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    HapticFeedback.lightImpact();
    _ctrl.forward(from: 0);
    widget.onPressed();
    await SoundService.instance?.confirm();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return ScaleTransition(
      scale: _scale,
      child: IconButton(
        tooltip: widget.bookmarked ? 'Remove bookmark' : 'Save',
        visualDensity: VisualDensity.compact,
        onPressed: _tap,
        icon: Icon(
          widget.bookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          color: colors.accentGold,
        ),
      ),
    );
  }
}
