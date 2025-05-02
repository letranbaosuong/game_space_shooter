import 'package:flutter/material.dart';
import 'package:game_space_shooter/widgets/space_shooter_game.dart';

class ScoreDisplay extends StatelessWidget {
  final SpaceShooterGame game;

  const ScoreDisplay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 20,
      child: Text(
        'Score: ${game.score}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
