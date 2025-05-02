import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:game_space_shooter/screens/game_screen.dart';
import 'package:game_space_shooter/utils/game_settings.dart';

// Tạo một màn hình menu chính mới
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Tải các thiết lập game
    await GameSettings().loadSettings();

    // Phát nhạc nền menu nếu nhạc được bật
    if (GameSettings().musicEnabled) {
      FlameAudio.bgm.play('menu_music.wav', volume: GameSettings().musicVolume);
    }
  }

  @override
  void dispose() {
    // Dừng nhạc khi rời khỏi màn hình menu
    FlameAudio.bgm.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Sử dụng hình ảnh từ assets làm nền
          image: DecorationImage(
            image: AssetImage("assets/images/space_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo trò chơi
              const Text(
                "SPACE\nSHOOTER",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.blue,
                      offset: Offset(0, 0),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),

              // Nút chơi game
              _buildMenuButton(
                context,
                "PLAY",
                Icons.play_arrow,
                Colors.green,
                () => _navigateToGame(context),
              ),

              const SizedBox(height: 20),

              // Nút cài đặt
              _buildMenuButton(
                context,
                "SETTINGS",
                Icons.settings,
                Colors.orange,
                () => _showSettingsDialog(context),
              ),

              const SizedBox(height: 20),

              // Nút hướng dẫn
              _buildMenuButton(
                context,
                "HOW TO PLAY",
                Icons.help_outline,
                Colors.blue,
                () => _showHowToPlay(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm tạo nút menu với hiệu ứng
  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28),
        label: Text(
          text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  // Cập nhật tất cả các phương thức có sử dụng âm thanh
  void _navigateToGame(BuildContext context) {
    // Phát âm thanh khi bấm nút
    GameSettings().playSfx('button_click.ogg');

    // Dừng nhạc menu trước khi chuyển sang màn hình game
    FlameAudio.bgm.stop();

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const GameScreen()));
  }

  // Trong class MainMenuScreen, cập nhật phương thức _showSettingsDialog
  void _showSettingsDialog(BuildContext context) {
    // Phát âm thanh khi bấm nút
    GameSettings().playSfx('button_click.ogg');

    showDialog(context: context, builder: (context) => SettingsDialog());
  }

  // // Hiển thị hộp thoại cài đặt
  // void _showSettingsDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           backgroundColor: Colors.black87,
  //           title: const Text(
  //             'Settings',
  //             style: TextStyle(color: Colors.white),
  //             textAlign: TextAlign.center,
  //           ),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               _buildSettingOption('Music', true),
  //               _buildSettingOption('Sound Effects', true),
  //               _buildSettingOption('Vibration', false),
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //               child: const Text(
  //                 'CLOSE',
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               onPressed: () => Navigator.of(context).pop(),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  // // Tạo một tùy chọn cài đặt với switch
  // Widget _buildSettingOption(String title, bool initialValue) {
  //   return StatefulBuilder(
  //     builder: (context, setState) {
  //       return Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 8.0),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               title,
  //               style: const TextStyle(color: Colors.white, fontSize: 16),
  //             ),
  //             Switch(
  //               value: initialValue,
  //               activeColor: Colors.blue,
  //               onChanged: (value) {
  //                 setState(() => initialValue = value);
  //                 // Xử lý thay đổi cài đặt
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Hiển thị hướng dẫn chơi
  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              'How To Play',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.arrow_upward, color: Colors.white),
                Text(
                  'Use arrow buttons to move your ship',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Icon(Icons.flash_on, color: Colors.yellow),
                Text(
                  'Tap fire button to shoot lasers',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Icon(Icons.catching_pokemon, color: Colors.blue),
                Text(
                  'Collect power-ups to enhance your ship',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text(
                  'GOT IT!',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }
}
