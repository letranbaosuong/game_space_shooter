import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_space_shooter/utils/game_settings.dart';
import 'package:game_space_shooter/widgets/enemy.dart';
import 'package:game_space_shooter/widgets/player.dart';
import 'package:game_space_shooter/widgets/power_up.dart';

class SpaceShooterGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection, TapDetector {
  late Player player;
  final Random random = Random();
  int score = 0;
  double enemySpawnTimer = 0;
  double powerUpTimer = 0;
  int difficulty = 1;
  double scoreTimer = 0;
  bool gameOver = false;
  int playerLives = 3;
  bool isShooting = false;
  bool isPaused = false; // Thêm trạng thái tạm dừng

  // Theo dõi trạng thái của các phím
  final Set<LogicalKeyboardKey> _keysPressed = {};

  bool isKeyPressed(LogicalKeyboardKey key) {
    return _keysPressed.contains(key);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Thêm hình nền không gian
    add(
      SpriteComponent(
        sprite: await loadSprite(
          'space_background.png',
        ), // Thay bằng hình nền thực tế
        size: size,
      )..priority = -1,
    );

    // Tạo người chơi và đặt ở dưới màn hình
    player = Player();
    add(player);
    player.position = Vector2(size.x / 2, size.y - 200);

    // Hiển thị điểm số, mạng sống và điều khiển cảm ứng
    overlays.add('score');
    overlays.add('lives');
    overlays.add('controls');
    overlays.add('pauseButton'); // Thêm nút tạm dừng

    // Khởi tạo audio
    await _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await FlameAudio.audioCache.loadAll([
        'laser_sound.ogg',
        'explosion.ogg',
        'powerup.ogg',
        'game_music.wav',
      ]);

      // Phát nhạc nền
      FlameAudio.bgm.play('game_music.wav', volume: 0.5);
    } catch (e) {
      debugPrint('Không thể tải audio: $e');
    }
  }

  // Tạm dừng game
  void pauseGame() {
    isPaused = true;
    // Tạm dừng nhạc nền
    FlameAudio.bgm.pause();
  }

  // Tiếp tục game
  void resumeGame() {
    isPaused = false;
    // Tiếp tục phát nhạc nền
    FlameAudio.bgm.resume();
  }

  @override
  void update(double dt) {
    if (isPaused) return; // Bỏ qua update nếu game đang tạm dừng
    super.update(dt);

    if (gameOver) return;

    // Đếm thời gian để tăng độ khó
    scoreTimer += dt;
    if (scoreTimer >= 5) {
      score += 10; // Điểm thưởng theo thời gian sống sót
      scoreTimer = 0;

      // Tăng độ khó sau mỗi 30 giây
      if (score % 100 == 0 && difficulty < 10) {
        // Giới hạn độ khó tối đa
        difficulty++;
      }
    }

    // Tạo kẻ địch theo thời gian
    enemySpawnTimer += dt;
    if (enemySpawnTimer >= max(0.5, 1.5 - (difficulty * 0.1))) {
      // Đảm bảo giá trị không âm
      spawnEnemy();
      enemySpawnTimer = 0;
    }

    // Tạo power-up theo thời gian
    powerUpTimer += dt;
    if (powerUpTimer >= 10.0) {
      spawnPowerUp();
      powerUpTimer = 0;
    }

    // Bắn liên tục nếu đang giữ nút bắn
    if (isShooting) {
      player.autoShoot(dt);
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // Cập nhật trạng thái phím
    _keysPressed.clear();
    _keysPressed.addAll(keysPressed);

    final isKeyDown = event is KeyDownEvent;

    if (event.logicalKey == LogicalKeyboardKey.space &&
        isKeyDown &&
        !gameOver) {
      player.shootLaser();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // Xử lý tap để bắn
  @override
  void onTapDown(TapDownInfo info) {
    if (!gameOver) {
      player.shootLaser();
    }
    super.onTapDown(info);
  }

  void spawnEnemy() {
    final enemy = Enemy();
    double x = random.nextDouble() * (size.x - 50);
    enemy.position = Vector2(x, -50);
    add(enemy);

    // Thêm hiệu ứng di chuyển cho kẻ địch
    final moveSpeed = 100 + (difficulty * 20);
    final distance = size.y + 150; // Khoảng cách di chuyển
    final duration = max(
      0.1,
      distance / moveSpeed,
    ); // Đảm bảo thời gian luôn dương

    enemy.add(
      MoveToEffect(
        Vector2(enemy.position.x, size.y + 100),
        EffectController(duration: duration),
        onComplete: () => enemy.removeFromParent(),
      ),
    );
  }

  void spawnPowerUp() {
    final types = ['speed', 'shield', 'extraLife', 'multiShot'];
    final type = types[random.nextInt(types.length)];

    final powerUp = PowerUp(type);
    double x = random.nextDouble() * (size.x - 30);
    powerUp.position = Vector2(x, -30);
    add(powerUp);

    powerUp.add(
      MoveToEffect(
        Vector2(powerUp.position.x, size.y + 50),
        EffectController(duration: 4.0),
        onComplete: () => powerUp.removeFromParent(),
      ),
    );
  }

  void playerHit() {
    playerLives--;

    // Phát âm thanh va chạm
    // FlameAudio.play('explosion.ogg', volume: 0.3);
    GameSettings().playSfx('explosion.ogg');

    // Cập nhật hiển thị mạng sống
    overlays.remove('lives');
    overlays.add('lives');

    // Thêm hiệu ứng khi người chơi bị trúng đạn
    add(
      ParticleSystemComponent(
        position: player.position,
        particle: Particle.generate(
          count: 20,
          lifespan: 0.5,
          generator:
              (i) => AcceleratedParticle(
                acceleration: Vector2(0, 30),
                speed: Vector2(
                  random.nextDouble() * 100 - 50,
                  random.nextDouble() * 100 - 50,
                ),
                child: CircleParticle(
                  radius: 2,
                  paint: Paint()..color = Colors.orange,
                ),
              ),
        ),
      ),
    );

    if (playerLives <= 0) {
      gameOver = true;

      // Dừng nhạc nền
      FlameAudio.bgm.stop();

      overlays.add('gameOver');
    }
  }

  void addScore(int points) {
    score += points;
  }

  // Cập nhật phương thức restart để cũng đặt lại isPaused
  void restart() {
    score = 0;
    difficulty = 1;
    playerLives = 3;
    gameOver = false;
    isPaused = false; // Đặt lại trạng thái tạm dừng

    // Xóa tất cả các thực thể trừ người chơi và background
    final componentsToRemove =
        children
            .whereType<Component>()
            .where((c) => c is! Player && c is! SpriteComponent)
            .toList();

    for (final component in componentsToRemove) {
      remove(component);
    }

    // Đặt lại vị trí người chơi
    player.position = Vector2(size.x / 2, size.y - 200);

    // Phát nhạc nền lại
    FlameAudio.bgm.play('game_music.wav', volume: 0.5);

    // Cập nhật overlays
    overlays.remove('gameOver');
    overlays.remove('lives');
    overlays.add('lives');
  }

  // Điều khiển player thông qua phương thức
  void movePlayerLeft() {
    player.moveLeft();
  }

  void movePlayerRight() {
    player.moveRight();
  }

  void movePlayerUp() {
    player.moveUp();
  }

  void movePlayerDown() {
    player.moveDown();
  }

  void stopHorizontalMovement() {
    player.stopHorizontalMovement();
  }

  void stopVerticalMovement() {
    player.stopVerticalMovement();
  }

  void stopPlayerMovement() {
    player.stopMovement();
  }

  void startShooting() {
    isShooting = true;
  }

  void stopShooting() {
    isShooting = false;
  }
}
