// Cập nhật lớp GameOverMenu để thêm nút chia sẻ và trở về menu
import 'package:flutter/material.dart';
import 'package:game_space_shooter/screens/menu_screen.dart';
import 'package:game_space_shooter/utils/game_settings.dart';
import 'package:game_space_shooter/widgets/space_shooter_game.dart';
import 'package:share_plus/share_plus.dart';

// Cập nhật các nút trong GameOverMenu
class GameOverMenu extends StatelessWidget {
  final SpaceShooterGame game;

  const GameOverMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blueAccent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              spreadRadius: 5,
              blurRadius: 7,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.blue,
                    offset: Offset(0, 0),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: ${game.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    GameSettings().playSfx('button_click.ogg');
                    game.restart();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.replay),
                      SizedBox(width: 8),
                      Text('Play Again', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () {
                    GameSettings().playSfx('button_click.ogg');
                    _shareScore(context, game.score);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                // Trở về màn hình menu chính
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MainMenuScreen(),
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Back to Menu',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Chia sẻ điểm số qua mạng xã hội
  void _shareScore(BuildContext context, int score) {
    Share.share(
      'Tôi vừa đạt được $score điểm trong Space Shooter! Bạn có thể phá đảo không?',
    );

    // Hiện tại chỉ hiển thị thông báo
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã đạt được $score điểm!')));
  }
}
