// Thêm nút tạm dừng game
import 'package:flutter/material.dart';
import 'package:game_space_shooter/screens/menu_screen.dart';
import 'package:game_space_shooter/widgets/space_shooter_game.dart';

class PauseButton extends StatelessWidget {
  final SpaceShooterGame game;

  const PauseButton(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 10,
      child: GestureDetector(
        onTap: () => _showPauseMenu(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(100),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.pause, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  void _showPauseMenu(BuildContext context) {
    game.pauseGame();

    showDialog(
      context: context,
      barrierDismissible: false, // Không thể đóng bằng cách nhấn bên ngoài
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              'Game Paused',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    game.resumeGame();
                  },
                  child: const Text('Resume', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Trở về màn hình menu chính
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MainMenuScreen(),
                      ),
                    );
                  },
                  child: const Text('Quit', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
    );
  }
}
