// Tạo một widget riêng cho dialog cài đặt
import 'package:flutter/material.dart';
import 'package:game_space_shooter/utils/game_settings.dart';

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
