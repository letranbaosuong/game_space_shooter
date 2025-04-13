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

// Thay đổi trong hàm main để bắt đầu với MainMenuScreen
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
        home: const MainMenuScreen(), // Thay đổi ở đây để start từ menu
      ),
    );
  });
}

// Tạo một màn hình menu chính mới
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Sử dụng hình ảnh từ assets làm nền
          image: DecorationImage(
            image: AssetImage("assets/images/space_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo trò chơi
              const Text(
                "SPACE\nSHOOTER",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.blue,
                      offset: Offset(0, 0),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),

              // Nút chơi game
              _buildMenuButton(
                context,
                "PLAY",
                Icons.play_arrow,
                Colors.green,
                () => _navigateToGame(context),
              ),

              const SizedBox(height: 20),

              // Nút cài đặt
              _buildMenuButton(
                context,
                "SETTINGS",
                Icons.settings,
                Colors.orange,
                () => _showSettingsDialog(context),
              ),

              const SizedBox(height: 20),

              // Nút hướng dẫn
              _buildMenuButton(
                context,
                "HOW TO PLAY",
                Icons.help_outline,
                Colors.blue,
                () => _showHowToPlay(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm tạo nút menu với hiệu ứng
  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28),
        label: Text(
          text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  // Chuyển đến màn hình game
  void _navigateToGame(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const GameScreen()));
  }

  // Hiển thị hộp thoại cài đặt
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSettingOption('Music', true),
                _buildSettingOption('Sound Effects', true),
                _buildSettingOption('Vibration', false),
              ],
            ),
            actions: [
              TextButton(
                child: const Text(
                  'CLOSE',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  // Tạo một tùy chọn cài đặt với switch
  Widget _buildSettingOption(String title, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Switch(
                value: initialValue,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() => initialValue = value);
                  // Xử lý thay đổi cài đặt
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Hiển thị hướng dẫn chơi
  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              'How To Play',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.arrow_upward, color: Colors.white),
                Text(
                  'Use arrow buttons to move your ship',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Icon(Icons.flash_on, color: Colors.yellow),
                Text(
                  'Tap fire button to shoot lasers',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Icon(Icons.catching_pokemon, color: Colors.blue),
                Text(
                  'Collect power-ups to enhance your ship',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text(
                  'GOT IT!',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }
}

// Thêm nút tạm dừng game
class PauseButton extends StatelessWidget {
  final SpaceShooterGame game;

  const PauseButton(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 10,
      child: GestureDetector(
        onTap: () => _showPauseMenu(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(100),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.pause, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  void _showPauseMenu(BuildContext context) {
    game.pauseGame();

    showDialog(
      context: context,
      barrierDismissible: false, // Không thể đóng bằng cách nhấn bên ngoài
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              'Game Paused',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    game.resumeGame();
                  },
                  child: const Text('Resume', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Trở về màn hình menu chính
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MainMenuScreen(),
                      ),
                    );
                  },
                  child: const Text('Quit', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
    );
  }
}

// Cập nhật lớp GameScreen để thêm overlay pauseButton
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
          'pauseButton':
              (context, game) =>
                  PauseButton(game as SpaceShooterGame), // Thêm nút tạm dừng
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

// Cập nhật lớp GameOverMenu để thêm nút chia sẻ và trở về menu
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
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blueAccent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              spreadRadius: 5,
              blurRadius: 7,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.blue,
                    offset: Offset(0, 0),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: ${game.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    game.restart();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.replay),
                      SizedBox(width: 8),
                      Text('Play Again', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () {
                    _shareScore(context, game.score);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                // Trở về màn hình menu chính
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MainMenuScreen(),
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Back to Menu',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Chia sẻ điểm số qua mạng xã hội
  void _shareScore(BuildContext context, int score) {
    // Phần này cần bạn thêm package share_plus vào dự án
    // Thêm dòng này vào pubspec.yaml: share_plus: ^latest_version
    // Và thêm import: import 'package:share_plus/share_plus.dart';

    // Khi đã thêm package, bỏ comment dòng này:
    // Share.share('Tôi vừa đạt được $score điểm trong Space Shooter! Bạn có thể phá đảo không?');

    // Hiện tại chỉ hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã đạt được $score điểm! (Chức năng chia sẻ đang được phát triển)',
        ),
      ),
    );
  }
}

// Thêm các thuộc tính và phương thức cần thiết vào SpaceShooterGame
/* Thêm vào class SpaceShooterGame:
  bool isPaused = false; // Thêm trạng thái tạm dừng

  // Tạm dừng game
  void pauseGame() {
    isPaused = true;
    // Tạm dừng nhạc nền nếu đang phát
    FlameAudio.bgm.pause();
  }

  // Tiếp tục game
  void resumeGame() {
    isPaused = false;
    // Tiếp tục phát nhạc nền
    FlameAudio.bgm.resume();
  }

  // Cập nhật phương thức update để kiểm tra isPaused
  @override
  void update(double dt) {
    if (isPaused) return; // Bỏ qua update nếu game đang tạm dừng
    
    super.update(dt);
    // Code hiện tại...
  }

  // Cập nhật restart để reset isPaused
  void restart() {
    // Code hiện tại...
    isPaused = false;
    // ...
  }
*/

// Thêm vào phương thức onLoad của SpaceShooterGame:
/*
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Code hiện tại...

    // Thêm dòng này
    overlays.add('pauseButton');
  }
*/

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

  @override
  void update(double dt) {
    // Không xử lý cập nhật khi game đang tạm dừng
    if (gameRef.isPaused) return;

    super.update(dt);
  }
}
