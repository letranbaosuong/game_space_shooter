import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:game_space_shooter/widgets/game_over_menu.dart';
import 'package:game_space_shooter/widgets/lives_display.dart';
import 'package:game_space_shooter/widgets/pause_button.dart';
import 'package:game_space_shooter/widgets/score_display.dart';
import 'package:game_space_shooter/widgets/space_shooter_game.dart';
import 'package:game_space_shooter/widgets/touch_controls.dart';

// Cập nhật lớp GameScreen để thêm overlay pauseButton
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: SpaceShooterGame(),
        loadingBuilder:
            (context) => const Center(child: CircularProgressIndicator()),
        overlayBuilderMap: {
          'gameOver': (context, game) => GameOverMenu(game as SpaceShooterGame),
          'score': (context, game) => ScoreDisplay(game as SpaceShooterGame),
          'controls':
              (context, game) => TouchControls(game as SpaceShooterGame),
          'lives': (context, game) => LivesDisplay(game as SpaceShooterGame),
          'pauseButton':
              (context, game) =>
                  PauseButton(game as SpaceShooterGame), // Thêm nút tạm dừng
        },
      ),
    );
  }
}
