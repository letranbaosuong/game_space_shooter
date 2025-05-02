import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game_space_shooter/widgets/space_shooter_game.dart';

class Laser extends SpriteComponent
    with CollisionCallbacks, HasGameRef<SpaceShooterGame> {
  final double speed = 500.0;

  Laser() : super(size: Vector2(5, 15));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await gameRef.loadSprite('laser.png'); // Thay bằng sprite thực tế
    paint = Paint()..color = Colors.redAccent;

    // Thêm hitbox
    add(RectangleHitbox(size: size));
  }

  @override
  void update(double dt) {
    // Không xử lý cập nhật khi game đang tạm dừng
    if (gameRef.isPaused) return;

    super.update(dt);

    // Di chuyển đạn lên trên với tốc độ cố định
    position.y -= speed * dt;

    // Xoá đạn khi ra khỏi màn hình
    if (position.y < -size.y) {
      removeFromParent();
    }
  }
}
