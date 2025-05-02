import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:game_space_shooter/utils/game_settings.dart';
import 'package:game_space_shooter/widgets/laser.dart';
import 'package:game_space_shooter/widgets/space_shooter_game.dart';

class Enemy extends SpriteComponent
    with CollisionCallbacks, HasGameRef<SpaceShooterGame> {
  Enemy() : super(size: Vector2(40, 40));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await gameRef.loadSprite(
      'enemy_ship.png',
    ); // Thay bằng sprite thực tế

    // Thêm hitbox
    add(
      CircleHitbox(radius: 15)
        ..position = size / 2
        ..anchor = Anchor.center,
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Laser) {
      // Thêm hiệu ứng nổ
      gameRef.add(
        ParticleSystemComponent(
          position: position + size / 2,
          particle: Particle.generate(
            count: 15,
            lifespan: 0.3,
            generator:
                (i) => AcceleratedParticle(
                  acceleration: Vector2(0, 20),
                  speed: Vector2(
                    gameRef.random.nextDouble() * 80 - 40,
                    gameRef.random.nextDouble() * 80 - 40,
                  ),
                  child: CircleParticle(
                    radius: 3,
                    paint: Paint()..color = Colors.yellowAccent,
                  ),
                ),
          ),
        ),
      );

      // Phát âm thanh nổ
      // FlameAudio.play('explosion.ogg', volume: 0.6);
      GameSettings().playSfx('explosion.ogg');

      removeFromParent();
      other.removeFromParent();

      // Tăng điểm
      gameRef.addScore(10);
    }

    super.onCollision(intersectionPoints, other);
  }
}
