import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/particles.dart';
import 'package:flame/effects.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Thiết lập hướng màn hình chỉ cho phép dọc
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(
      MaterialApp(
        title: 'Space Shooter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const GameScreen(),
      ),
    );
  });
}

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
        },
      ),
    );
  }
}

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

class LivesDisplay extends StatelessWidget {
  final SpaceShooterGame game;

  const LivesDisplay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      child: Row(
        children: List.generate(
          game.playerLives,
          (index) => const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.favorite, color: Colors.red, size: 24),
          ),
        ),
      ),
    );
  }
}

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
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: ${game.score}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                game.restart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text('Play Again', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

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

  @override
  void update(double dt) {
    super.update(dt);

    if (gameOver) return;

    // Đếm thời gian để tăng độ khó
    scoreTimer += dt;
    if (scoreTimer >= 5) {
      score += 10; // Điểm thưởng theo thời gian sống sót
      scoreTimer = 0;

      // Tăng độ khó sau mỗi 30 giây
      if (score % 100 == 0) {
        difficulty++;
      }
    }

    // Tạo kẻ địch theo thời gian
    enemySpawnTimer += dt;
    if (enemySpawnTimer >= 1.5 - (difficulty * 0.1).clamp(0.0, 1.0)) {
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
    final duration =
        distance / moveSpeed; // Thời gian di chuyển dựa vào tốc độ thực

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
    FlameAudio.play('explosion.ogg', volume: 0.3);

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

  void restart() {
    score = 0;
    difficulty = 1;
    playerLives = 3;
    gameOver = false;

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

  Player() : super(size: Vector2(50, 50));

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
    autoShootDelay -= dt;

    if (autoShootDelay <= 0) {
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
    FlameAudio.play('laser_sound.ogg', volume: 0.4);

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
      FlameAudio.play('powerup.ogg', volume: 0.5);

      applyPowerUp(other.type);
      other.removeFromParent();
    }

    super.onCollision(intersectionPoints, other);
  }
}

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
    super.update(dt);

    // Di chuyển đạn lên trên với tốc độ cố định
    position.y -= speed * dt;

    // Xoá đạn khi ra khỏi màn hình
    if (position.y < -size.y) {
      removeFromParent();
    }
  }
}

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
      FlameAudio.play('explosion.ogg', volume: 0.6);

      removeFromParent();
      other.removeFromParent();

      // Tăng điểm
      gameRef.addScore(10);
    }

    super.onCollision(intersectionPoints, other);
  }
}

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
}
