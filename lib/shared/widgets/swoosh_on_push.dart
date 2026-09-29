import 'package:flutter/material.dart';

import '../../core/sound/sound_service.dart';

/// Plays the page-swoosh once when a pushed route first appears.
class SwooshOnPush extends StatefulWidget {
  const SwooshOnPush({super.key, required this.child});

  final Widget child;

  @override
  State<SwooshOnPush> createState() => _SwooshOnPushState();
}

class _SwooshOnPushState extends State<SwooshOnPush> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundService.instance?.swoosh();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
