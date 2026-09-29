import 'package:url_launcher/url_launcher.dart';

/// Parse YouTube URLs and open them in the YouTube app, with HTTPS fallback.
class Youtube {
  Youtube._();

  static final _idPattern = RegExp(r'^[a-zA-Z0-9_-]{11}$');

  static String? videoId(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    if (_idPattern.hasMatch(text)) return text;

    var uri = Uri.tryParse(text);
    if (uri == null ||
        (uri.host.isEmpty &&
            (text.contains('youtube') || text.contains('youtu.be')))) {
      uri = Uri.tryParse(text.startsWith('http') ? text : 'https://$text');
    }
    if (uri == null) return null;

    final v = uri.queryParameters['v'];
    if (v != null && _idPattern.hasMatch(v)) return v;

    final host = uri.host.replaceFirst('www.', '');
    if (host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      final id = uri.pathSegments.first;
      if (_idPattern.hasMatch(id)) return id;
    }

    final segs = uri.pathSegments;
    for (var i = 0; i < segs.length - 1; i++) {
      if (const {'embed', 'live', 'shorts', 'v'}.contains(segs[i]) &&
          _idPattern.hasMatch(segs[i + 1])) {
        return segs[i + 1];
      }
    }
    if (segs.isNotEmpty && _idPattern.hasMatch(segs.last)) return segs.last;
    return null;
  }

  static String thumbnailUrl(String videoId) =>
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  static String watchUrl(String videoId) =>
      'https://www.youtube.com/watch?v=$videoId';

  static String? resolvedThumbnail(String youtubeUrl, [String? override]) {
    if (override != null && override.trim().isNotEmpty) return override.trim();
    final id = videoId(youtubeUrl);
    if (id == null) return null;
    return thumbnailUrl(id);
  }

  /// Prefer the YouTube app, then the browser.
  static Future<bool> open(String url) async {
    final id = videoId(url);
    if (id == null) {
      final uri = Uri.tryParse(url.trim());
      if (uri == null) return false;
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    final https = Uri.parse(watchUrl(id));
    final appUris = [
      Uri.parse('youtube://www.youtube.com/watch?v=$id'),
      Uri.parse('vnd.youtube:$id'),
    ];

    for (final app in appUris) {
      try {
        if (await canLaunchUrl(app)) {
          final ok = await launchUrl(app, mode: LaunchMode.externalApplication);
          if (ok) return true;
        }
      } catch (_) {
        // Scheme not declared or no handler — try the next option.
      }
    }

    return launchUrl(https, mode: LaunchMode.externalApplication);
  }
}
