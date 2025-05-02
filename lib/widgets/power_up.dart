import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:game_space_shooter/widgets/space_shooter_game.dart';

class PowerUp extends SpriteComponent
    with CollisionCallbacks, HasGameRef<SpaceShooterGame> {
  final String type;

  PowerUp(this.type) : super(size: Vector2(30, 30));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load sprite tương ứng với loại power-up
    String assetName;
    switch (type) {
      case 'speed':
        assetName = 'powerup_speed.png';
        break;
      case 'shield':
        assetName = 'powerup_shield.png';
        break;
      case 'extraLife':
        assetName = 'powerup_life.png';
        break;
      case 'multiShot':
        assetName = 'powerup_multishot.png';
        break;
      default:
        assetName = 'powerup_default.png';
    }

    sprite = await gameRef.loadSprite(assetName); // Thay bằng sprite thực tế

    // Thêm hiệu ứng xoay cho power-up
    add(RotateEffect.by(2 * pi, EffectController(duration: 3, infinite: true)));

    // Thêm hitbox
    add(
      CircleHitbox(radius: 15)
        ..position = size / 2
        ..anchor = Anchor.center,
    );
  }

  @override
  void update(double dt) {
    // Không xử lý cập nhật khi game đang tạm dừng
    if (gameRef.isPaused) return;

    super.update(dt);
  }
}
