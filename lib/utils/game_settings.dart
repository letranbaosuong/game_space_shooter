// Đầu tiên, tạo một lớp để quản lý các cài đặt trên toàn ứng dụng
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:game_space_shooter/widgets/space_shooter_game.dart';
import 'package:share_plus/share_plus.dart';
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

// Tạo một widget riêng cho dialog cài đặt
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final GameSettings _settings = GameSettings();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      title: const Text(
        'Settings',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSettingSwitch('Music', _settings.musicEnabled, (value) {
            setState(() {
              _settings.musicEnabled = value;
              _settings.saveSettings();
            });
          }),
          _buildSettingSwitch('Sound Effects', _settings.soundEffectsEnabled, (
            value,
          ) {
            setState(() {
              _settings.soundEffectsEnabled = value;
              _settings.saveSettings();

              // Phát âm thanh test nếu bật
              if (value) {
                _settings.playSfx('button_click.ogg');
              }
            });
          }),
          _buildSettingSwitch('Vibration', _settings.vibrationEnabled, (value) {
            setState(() {
              _settings.vibrationEnabled = value;
              _settings.saveSettings();

              // Rung thử nếu bật
              if (value) {
                _settings.vibrate();
              }
            });
          }),
          const SizedBox(height: 20),
          // Thêm 2 thanh trượt cho âm lượng
          _buildVolumeSlider('Music Volume', _settings.musicVolume, (value) {
            setState(() {
              _settings.musicVolume = value;
              _settings.saveSettings();
            });
          }),
          _buildVolumeSlider('Sound Volume', _settings.soundVolume, (value) {
            setState(() {
              _settings.soundVolume = value;
              _settings.saveSettings();
              // Phát âm thanh thử với âm lượng mới
              _settings.playSfx('button_click.ogg');
            });
          }),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('CLOSE', style: TextStyle(color: Colors.white)),
          onPressed: () {
            _settings.playSfx('button_click.ogg');
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  // Widget cho switch cài đặt
  Widget _buildSettingSwitch(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Switch(
            value: value,
            activeColor: Colors.blue,
            onChanged: (newValue) {
              onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }

  // Widget cho thanh trượt âm lượng
  Widget _buildVolumeSlider(
    String title,
    double value,
    Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Row(
            children: [
              const Icon(Icons.volume_down, color: Colors.white),
              Expanded(
                child: Slider(
                  value: value,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                  onChanged: (newValue) {
                    onChanged(newValue);
                  },
                ),
              ),
              const Icon(Icons.volume_up, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

// Cập nhật các đoạn gọi âm thanh trong toàn ứng dụng
// Ví dụ: thay thế FlameAudio.play() bằng GameSettings().playSfx()

// Cập nhật các nút trong GameOverMenu
class GameOverMenu extends StatelessWidget {
  final SpaceShooterGame game;

  const GameOverMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // ...phần style không thay đổi
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ...phần UI không thay đổi
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    GameSettings().playSfx('button_click.ogg');
                    game.restart();
                  },
                  // ...style không thay đổi
                  child: const Text('Play Again'),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () {
                    GameSettings().playSfx('button_click.ogg');
                    _shareScore(context, game.score);
                  },
                  // ...style không thay đổi
                  child: const Text('Share'),
                ),
              ],
            ),
            // ...UI còn lại không thay đổi
          ],
        ),
      ),
    );
  }

  void _shareScore(BuildContext context, int score) {
    Share.share(
      'Tôi vừa đạt được $score điểm trong Space Shooter! Bạn có thể phá đảo không?',
    );

    // Hiện tại chỉ hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã đạt được $score điểm! (Chức năng chia sẻ đang được phát triển)',
        ),
      ),
    );
  }
}
