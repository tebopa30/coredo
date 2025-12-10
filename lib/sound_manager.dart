import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;

  SoundManager._internal();

  final ValueNotifier<bool> isSoundOn = ValueNotifier(true);

  final AudioPlayer _bgmPlayer = AudioPlayer();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isSoundOn.value = prefs.getBool('is_sound_on') ?? true;

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('audio/437_long_BPM120.mp3'));
    _updateVolume();

    isSoundOn.addListener(_updateVolume);
  }

  void _updateVolume() {
    _bgmPlayer.setVolume(isSoundOn.value ? 1.0 : 0.0);
  }

  Future<void> setSound(bool value) async {
    isSoundOn.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_sound_on', value);
  }
}
