// Đầu tiên, tạo một lớp để quản lý các cài đặt trên toàn ứng dụng
import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class GameSettings {
  // Singleton pattern
  static final GameSettings _instance = GameSettings._internal();
  factory GameSettings() => _instance;
  GameSettings._internal();

  // Các thiết lập mặc định
  bool musicEnabled = true;
  bool soundEffectsEnabled = true;
  bool vibrationEnabled = false;
  double musicVolume = 0.5;
  double soundVolume = 0.6;

  // SharedPreferences key
  static const String _keyMusicEnabled = 'music_enabled';
  static const String _keySoundEffectsEnabled = 'sound_effects_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  static const String _keyMusicVolume = 'music_volume';
  static const String _keySoundVolume = 'sound_volume';

  // Tải thiết lập từ SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    musicEnabled = prefs.getBool(_keyMusicEnabled) ?? true;
    soundEffectsEnabled = prefs.getBool(_keySoundEffectsEnabled) ?? true;
    vibrationEnabled = prefs.getBool(_keyVibrationEnabled) ?? false;
    musicVolume = prefs.getDouble(_keyMusicVolume) ?? 0.5;
    soundVolume = prefs.getDouble(_keySoundVolume) ?? 0.6;

    // Cập nhật âm thanh theo thiết lập
    _applyAudioSettings();
  }

  // Lưu thiết lập vào SharedPreferences
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMusicEnabled, musicEnabled);
    await prefs.setBool(_keySoundEffectsEnabled, soundEffectsEnabled);
    await prefs.setBool(_keyVibrationEnabled, vibrationEnabled);
    await prefs.setDouble(_keyMusicVolume, musicVolume);
    await prefs.setDouble(_keySoundVolume, soundVolume);

    // Cập nhật âm thanh theo thiết lập
    _applyAudioSettings();
  }

  // Áp dụng thiết lập âm thanh
  void _applyAudioSettings() {
    if (musicEnabled) {
      // Bật nhạc nền với âm lượng đã thiết lập
      FlameAudio.bgm.audioPlayer.setVolume(musicVolume);
    } else {
      // Tắt nhạc nền
      FlameAudio.bgm.pause();
    }
  }

  // Phát âm thanh hiệu ứng với thiết lập đã cấu hình
  Future<void> playSfx(String filename) async {
    if (soundEffectsEnabled) {
      await FlameAudio.play(filename, volume: soundVolume);
    }
  }

  // Rung thiết bị (nếu được hỗ trợ và được bật)
  Future<void> vibrate() async {
    if (vibrationEnabled) {
      // Cần thêm import: import 'package:vibration/vibration.dart';
      // Kiểm tra xem thiết bị có hỗ trợ rung không
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 100);
      }
    }
  }
}
