import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

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
    await _bgmPlayer.play(AssetSource('audio/437_long_BPM120.mp3'), volume: isSoundOn.value ? 0.3 : 0.0);
    _updateVolume();

    isSoundOn.addListener(_updateVolume);
  }

  void _updateVolume() {
    _bgmPlayer.setVolume(isSoundOn.value ? 0.3 : 0.0);
  }

  Future<void> setSound(bool value) async {
    isSoundOn.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_sound_on', value);
  }
}

class AudioManager {
  static final AudioPlayer _player = AudioPlayer();

  static final List<String> _audioPaths = [
    'assets/いつもと違うジャンルに挑戦してみる？.m4a',
    'assets/お腹空いてきたね.m4a',
    'assets/それすごくいいね.m4a',
    'assets/決まりだね.m4a',
    'assets/今のお腹の空き具合は？.m4a',
    'assets/今日はどんな気分？.m4a',
    'assets/今日は何を食べようかな.m4a',
    'assets/初めてのお店に行ってみるのもいいよね.m4a',
    'assets/食べるのが楽しみだね.m4a',
    'assets/早く食べたいね.m4a',
    'assets/美味しいものを食べると幸せな気持ちになるよね.m4a',
    'assets/和洋中だとどの気分？.m4a',
  ];

  static void playRandom() {
    final randomPath = _audioPaths[Random().nextInt(_audioPaths.length)];
    _player.stop();
    _player.play(AssetSource(randomPath));
  }

  static void dispose() {
    _player.stop();
    _player.release();
    _player.dispose();
  }
}