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
    'audio/1.m4a',
    'audio/2.m4a',
    'audio/3.m4a',
    'audio/4.m4a',
    'audio/5.m4a',
    //'audio/6.m4a',
    'audio/7.m4a',
    //'audio/8.m4a',
    //'audio/9.m4a',
    'audio/10.m4a',
    //'audio/11.m4a',
    'audio/12.m4a',
  ];

  static void playRandom() {
    final randomPath = _audioPaths[Random().nextInt(_audioPaths.length)];
    _player.stop();
    _player.setVolume(1.0);
    _player.play(AssetSource(randomPath));
  }

  static Future<void> play(String path) async {
    await _player.stop();
    await _player.setVolume(1.0);
    await _player.play(AssetSource(path));
  }
  static const List<String> setA = [
    'audio/8.m4a',
    'audio/9.m4a',
    'audio/11.m4a',
  ];
  
  static Future<void> playFromList(List<String> paths) async {
    final randomPath = paths[Random().nextInt(paths.length)];
    await _player.stop();
    await _player.setVolume(1.0);
    await _player.play(AssetSource(randomPath));
  }

  static Future<void> playSetA() async {
    await playFromList(setA);
  }

  static void dispose() {
    _player.stop();
    _player.release();
    _player.dispose();
  }
}