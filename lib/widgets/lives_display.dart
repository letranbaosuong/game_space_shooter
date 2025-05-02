import 'package:flutter/material.dart';
import 'package:game_space_shooter/widgets/space_shooter_game.dart';

class LivesDisplay extends StatelessWidget {
  final SpaceShooterGame game;

  const LivesDisplay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      child:
          game.playerLives > 0
              ? Row(
                children: List.generate(
                  game.playerLives,
                  (index) => const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.favorite, color: Colors.red, size: 24),
                  ),
                ),
              )
              : const SizedBox.shrink(),
    );
  }
}
