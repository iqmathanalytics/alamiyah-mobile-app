import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/display_prefs.dart';

class SoundService {
  SoundService(this._ref) {
    instance = this;
  }

  final Ref _ref;
  final AudioPlayer _player = AudioPlayer();

  static SoundService? instance;

  DisplayPrefs get _prefs => _ref.read(displayPrefsProvider);

  Future<void> tick() => _play('sounds/tick.wav', volume: 0.45);

  Future<void> settle() => _play('sounds/settle.wav', volume: 0.5);

  Future<void> swoosh() => _play('sounds/swoosh.wav', volume: 0.4);

  Future<void> confirm() => _play('sounds/confirm.wav', volume: 0.5);

  Future<void> previewChime([ChimeId? id]) =>
      _play((id ?? _prefs.chime).asset, ignoreMute: id != null);

  Future<void> _play(
    String asset, {
    bool ignoreMute = false,
    double volume = 0.55,
  }) async {
    if (!ignoreMute && !_prefs.soundEffects) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(asset), volume: volume);
    } catch (e) {
      debugPrint('Sound skipped: $e');
    }
  }
}

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService(ref);
  ref.onDispose(service._player.dispose);
  return service;
});
