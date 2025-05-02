import 'package:flutter/material.dart';
import 'package:game_space_shooter/widgets/space_shooter_game.dart';

class TouchControls extends StatelessWidget {
  final SpaceShooterGame game;

  const TouchControls(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Nút di chuyển
        Positioned(
          bottom: 10,
          left: 10,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                // Nút lên
                Positioned(
                  top: 5,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTapDown: (_) => game.movePlayerUp(),
                    onTapUp: (_) => game.stopVerticalMovement(),
                    onTapCancel: () => game.stopVerticalMovement(),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),

                // Nút trái
                Positioned(
                  left: 5,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTapDown: (_) => game.movePlayerLeft(),
                      onTapUp: (_) => game.stopHorizontalMovement(),
                      onTapCancel: () => game.stopHorizontalMovement(),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),

                // Nút phải
                Positioned(
                  right: 5,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTapDown: (_) => game.movePlayerRight(),
                      onTapUp: (_) => game.stopHorizontalMovement(),
                      onTapCancel: () => game.stopHorizontalMovement(),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),

                // Nút xuống
                Positioned(
                  bottom: 5,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTapDown: (_) => game.movePlayerDown(),
                    onTapUp: (_) => game.stopVerticalMovement(),
                    onTapCancel: () => game.stopVerticalMovement(),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_downward,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Nút bắn
        Positioned(
          bottom: 10,
          right: 10,
          child: GestureDetector(
            onTapDown: (_) => game.startShooting(),
            onTapUp: (_) => game.stopShooting(),
            onTapCancel: () => game.stopShooting(),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flash_on, color: Colors.yellow, size: 50),
            ),
          ),
        ),
      ],
    );
  }
}
