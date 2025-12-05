import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;

  SoundManager._internal();

  final ValueNotifier<bool> isSoundOn = ValueNotifier(true);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isSoundOn.value = prefs.getBool('is_sound_on') ?? true;
  }

  Future<void> setSound(bool value) async {
    isSoundOn.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_sound_on', value);
  }
}
