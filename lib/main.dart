import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/particles.dart';
import 'package:flame/effects.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Space Shooter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GameScreen(),
    ),
  );
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: SpaceShooterGame(),
        overlayBuilderMap: {
          'gameOver': (context, game) => GameOverMenu(game as SpaceShooterGame),
          'score': (context, game) => ScoreDisplay(game as SpaceShooterGame),
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
              child: const Text('Play Again', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

class SpaceShooterGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection {
  late Player player;
  final Random random = Random();
  int score = 0;
  double enemySpawnTimer = 0;
  double powerUpTimer = 0;
  int difficulty = 1;
  double scoreTimer = 0;
  bool gameOver = false;
  int playerLives = 3;

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
    player.position = Vector2(size.x / 2, size.y - 100);

    // Hiển thị điểm số
    overlays.add('score');
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
  }

  // Theo dõi trạng thái của các phím
  final Set<LogicalKeyboardKey> _keysPressed = {};

  bool isKeyPressed(LogicalKeyboardKey key) {
    return _keysPressed.contains(key);
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

  void spawnEnemy() {
    final enemy = Enemy();
    double x = random.nextDouble() * (size.x - 50);
    enemy.position = Vector2(x, -50);
    add(enemy);

    // Thêm hiệu ứng di chuyển cho kẻ địch
    final speed = 100 + (difficulty * 20);
    enemy.add(
      MoveToEffect(
        Vector2(enemy.position.x, size.y + 100),
        EffectController(duration: 3 - (difficulty * 0.2).clamp(0.0, 2.0)),
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

    // Xóa tất cả các thực thể trừ người chơi
    final componentsToRemove =
        children
            .whereType<Component>()
            .where((c) => c is! Player && c is! SpriteComponent)
            .toList();

    for (final component in componentsToRemove) {
      remove(component);
    }

    // Đặt lại vị trí người chơi
    player.position = Vector2(size.x / 2, size.y - 100);

    overlays.remove('gameOver');
  }
}

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameRef<SpaceShooterGame> {
  bool hasShield = false;
  bool hasMultiShot = false;
  double speed = 200.0;
  double shootCooldown = 0;

  Player() : super(size: Vector2(50, 50));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite(
      'player_ship.png',
    ); // Thay bằng sprite thực tế

    // Thêm hình dạng va chạm
    CircleHitbox(radius: 20)
      ..position = size / 2
      ..anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Xử lý di chuyển sử dụng hàm isKeyPressed trong game
    if (gameRef.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
      position.x -= speed * dt;
    }

    if (gameRef.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
      position.x += speed * dt;
    }

    // Giới hạn di chuyển trong màn hình
    position.x = position.x.clamp(0, gameRef.size.x - size.x);

    // Xử lý cooldown bắn đạn
    if (shootCooldown > 0) {
      shootCooldown -= dt;
    }
  }

  void shootLaser() {
    if (shootCooldown > 0) return;

    // Thiết lập cooldown
    shootCooldown = hasMultiShot ? 0.3 : 0.5;

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
        Future.delayed(const Duration(seconds: 5), () => speed = 200.0);
        break;
      case 'shield':
        hasShield = true;
        // Thêm hiệu ứng hình ảnh cho shield
        Future.delayed(const Duration(seconds: 7), () => hasShield = false);
        break;
      case 'extraLife':
        gameRef.playerLives = min(gameRef.playerLives + 1, 5);
        break;
      case 'multiShot':
        hasMultiShot = true;
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
      }
    }

    if (other is PowerUp) {
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
    RectangleHitbox(size: size);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Di chuyển đạn lên trên
    position.y -= speed * dt;

    // Xoá đạn khi ra khỏi màn hình
    if (position.y < -size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Enemy) {
      // Thêm hiệu ứng nổ
      gameRef.add(
        ParticleSystemComponent(
          position: other.position + other.size / 2,
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

      other.removeFromParent();
      removeFromParent();

      // Tăng điểm
      gameRef.addScore(10);
    }

    super.onCollision(intersectionPoints, other);
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
    CircleHitbox(radius: 15)
      ..position = size / 2
      ..anchor = Anchor.center;
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
    CircleHitbox(radius: 15)
      ..position = size / 2
      ..anchor = Anchor.center;
  }
}
