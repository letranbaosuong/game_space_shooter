import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_space_shooter/utils/game_settings.dart';
import 'package:game_space_shooter/widgets/enemy.dart';
import 'package:game_space_shooter/widgets/laser.dart';
import 'package:game_space_shooter/widgets/power_up.dart';
import 'package:game_space_shooter/widgets/space_shooter_game.dart';

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameRef<SpaceShooterGame> {
  bool hasShield = false;
  bool hasMultiShot = false;
  double speed = 200.0;
  double shootCooldown = 0;
  bool isMovingLeft = false;
  bool isMovingRight = false;
  bool isMovingUp = false;
  bool isMovingDown = false;

  // Thời gian giữa các phát bắn tự động
  double autoShootDelay = 0;

  Player() : super(size: Vector2(50, 50)) {
    // Khởi tạo giá trị autoShootDelay
    autoShootDelay = 0.5;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite(
      'player_ship.png',
    ); // Thay bằng sprite thực tế

    // Thêm hình dạng va chạm
    add(
      CircleHitbox(radius: 20)
        ..position = size / 2
        ..anchor = Anchor.center,
    );
  }

  @override
  void update(double dt) {
    // Không xử lý cập nhật khi game đang tạm dừng
    if (gameRef.isPaused) return;

    super.update(dt);

    // Xử lý di chuyển từ bàn phím và cảm ứng - ngang
    if (gameRef.isKeyPressed(LogicalKeyboardKey.arrowLeft) || isMovingLeft) {
      position.x -= speed * dt;
    }

    if (gameRef.isKeyPressed(LogicalKeyboardKey.arrowRight) || isMovingRight) {
      position.x += speed * dt;
    }

    // Xử lý di chuyển từ bàn phím và cảm ứng - dọc
    if (gameRef.isKeyPressed(LogicalKeyboardKey.arrowUp) || isMovingUp) {
      position.y -= speed * dt;
    }

    if (gameRef.isKeyPressed(LogicalKeyboardKey.arrowDown) || isMovingDown) {
      position.y += speed * dt;
    }

    // Giới hạn di chuyển trong màn hình
    position.x = position.x.clamp(0, gameRef.size.x - size.x);
    position.y = position.y.clamp(
      gameRef.size.y * 0.3,
      gameRef.size.y - size.y,
    );

    // Xử lý cooldown bắn đạn
    if (shootCooldown > 0) {
      shootCooldown -= dt;
    }
  }

  // Phương thức bắn tự động khi giữ nút
  void autoShoot(double dt) {
    if (autoShootDelay > 0) {
      autoShootDelay -= dt;
    } else {
      shootLaser();
      autoShootDelay = hasMultiShot ? 0.3 : 0.5; // Reset delay
    }
  }

  void moveLeft() {
    isMovingLeft = true;
    isMovingRight = false;
  }

  void moveRight() {
    isMovingRight = true;
    isMovingLeft = false;
  }

  void moveUp() {
    isMovingUp = true;
    isMovingDown = false;
  }

  void moveDown() {
    isMovingDown = true;
    isMovingUp = false;
  }

  void stopHorizontalMovement() {
    isMovingLeft = false;
    isMovingRight = false;
  }

  void stopVerticalMovement() {
    isMovingUp = false;
    isMovingDown = false;
  }

  void stopMovement() {
    stopHorizontalMovement();
    stopVerticalMovement();
  }

  void shootLaser() {
    if (shootCooldown > 0) return;

    // Thiết lập cooldown
    shootCooldown = hasMultiShot ? 0.3 : 0.5;

    // Phát âm thanh bắn laser
    // FlameAudio.play('laser_sound.ogg', volume: 0.4);
    GameSettings().playSfx('laser_sound.ogg');

    // Bắn đạn laser
    final laser = Laser();
    laser.position = Vector2(
      position.x + size.x / 2 - laser.size.x / 2,
      position.y,
    );
    gameRef.add(laser);

    // Nếu có power-up multiShot, bắn thêm đạn
    if (hasMultiShot) {
      // Đạn bên trái
      final leftLaser = Laser();
      leftLaser.position = Vector2(position.x + 10, position.y + 10);
      leftLaser.angle = -0.2;
      gameRef.add(leftLaser);

      // Đạn bên phải
      final rightLaser = Laser();
      rightLaser.position = Vector2(position.x + size.x - 10, position.y + 10);
      rightLaser.angle = 0.2;
      gameRef.add(rightLaser);
    }
  }

  void applyPowerUp(String type) {
    switch (type) {
      case 'speed':
        speed = 300.0;
        // Thêm hiệu ứng visual cho power-up speed
        add(
          ColorEffect(
            Colors.blue,
            EffectController(duration: 5.0),
            opacityTo: 0.5,
          ),
        );
        Future.delayed(const Duration(seconds: 5), () => speed = 200.0);
        break;
      case 'shield':
        hasShield = true;
        // Thêm hiệu ứng visual cho shield
        final shieldEffect = CircleComponent(
          radius: 25,
          position: size / 2,
          anchor: Anchor.center,
          paint: Paint()..color = Colors.blue.withValues(alpha: 0.3),
        );
        add(shieldEffect);
        Future.delayed(const Duration(seconds: 7), () {
          hasShield = false;
          remove(shieldEffect);
        });
        break;
      case 'extraLife':
        gameRef.playerLives = min(gameRef.playerLives + 1, 5);
        // Cập nhật hiển thị mạng sống
        gameRef.overlays.remove('lives');
        gameRef.overlays.add('lives');
        break;
      case 'multiShot':
        hasMultiShot = true;
        // Thêm hiệu ứng visual cho multi-shot
        add(
          ColorEffect(
            Colors.red,
            EffectController(duration: 8.0),
            opacityTo: 0.5,
          ),
        );
        Future.delayed(const Duration(seconds: 8), () => hasMultiShot = false);
        break;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Enemy) {
      other.removeFromParent();

      if (!hasShield) {
        gameRef.playerHit();
      } else {
        // Nếu có shield, chỉ mất shield
        hasShield = false;

        // Xóa tất cả các hiệu ứng shield
        children.whereType<CircleComponent>().forEach((shield) {
          shield.removeFromParent();
        });
      }
    }

    if (other is PowerUp) {
      // Phát âm thanh power-up
      // FlameAudio.play('powerup.ogg', volume: 0.5);
      GameSettings().playSfx('powerup.ogg');

      applyPowerUp(other.type);
      other.removeFromParent();
    }

    super.onCollision(intersectionPoints, other);
  }
}
