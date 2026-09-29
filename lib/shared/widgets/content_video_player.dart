import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/alamiyah_colors.dart';

/// In-app network video for content detail (mp4 and similar).
class ContentVideoPlayer extends StatefulWidget {
  const ContentVideoPlayer({super.key, required this.url});

  final String url;

  @override
  State<ContentVideoPlayer> createState() => _ContentVideoPlayerState();
}

class _ContentVideoPlayerState extends State<ContentVideoPlayer> {
  late final VideoPlayerController _controller;
  var _ready = false;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller
          ..setLooping(true)
          ..play();
      }).catchError((_) {
        if (!mounted) return;
        setState(() => _failed = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;

    if (_failed) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.chipBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Could not load video',
          style: TextStyle(color: colors.brandSecondary),
        ),
      );
    }

    if (!_ready) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.chipBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const CircularProgressIndicator(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio == 0
            ? 16 / 9
            : _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_controller),
            Positioned(
              right: 10,
              bottom: 10,
              child: Material(
                color: Colors.black.withValues(alpha: 0.45),
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: _controller.value.isPlaying ? 'Pause' : 'Play',
                  onPressed: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                    });
                  },
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool isPlayableVideoUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  final lower = url.toLowerCase();
  if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
    return false;
  }
  return lower.contains('.mp4') ||
      lower.contains('.m3u8') ||
      lower.contains('.mov') ||
      lower.contains('videos/bee');
}
