import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_network_assets/flame_network_assets.dart';
import 'package:flutter/material.dart';
import 'package:ny/audio/audio_manager.dart';
import 'package:ny/components/background.dart';
import 'package:ny/components/pipe.dart';
import 'package:ny/constants.dart';
import 'package:ny/managers/basket_manager.dart';
import 'package:ny/managers/escalator_manager.dart';
import 'package:ny/managers/fruit_manager.dart';
import 'package:ny/overlay/ny_overlay.dart';

void main() {
  runApp(GameWidget(game: MyWorld()));
}

class MyWorld extends FlameGame with TapCallbacks, HasCollisionDetection {
  final audio = NYAudioManager();
  final networkAssets = FlameNetworkImages();

  late Pipe pipe;
  late BasketManager basketManager;
  late Background background;
  late EscalatorManager escalator;
  late TextComponent scoreText;
  late TextComponent timerText;
  late TextComponent gameOverText;
  late ScreenBorderOverlay borderOverlay;

  final List<List<String>> patterns = [
    ["apple", "apple", "grape", "apple"],
    ["orange", "banana", "apple", "grape"],
    ["orange", "grape", "apple", "banana"],
    ["apple", "orange", "banana", "grape"],
    ["grape", "banana", "apple", "orange"],
    ["banana", "apple", "orange", "grape"],
    ["banana", "banana", "banana", "banana"],
    ["grape", "orange", "apple", "grape"],
    ["banana", "grape", "orange", "apple"],
    ["apple", "banana", "orange", "grape"],
  ];
  /*
    niit 5 jims bgaa 
    1 patternd 4 jims irh bolomjtoi 
    magadlal tootsoj jimsnuudig generatelh

  
  
   */

  List<Map<String, String>> networkImages = [
    {"apple": "https://cdn-icons-png.flaticon.com/256/415/415733.png"},
    {"pineapple": "https://cdn-icons-png.flaticon.com/256/8692/8692265.png"},
    {"grape": "https://cdn-icons-png.flaticon.com/256/5376/5376074.png"},
    {"banana": "https://cdn-icons-png.flaticon.com/256/831/831896.png"},
    {"orange": "https://cdn-icons-png.flaticon.com/256/1791/1791312.png"},
  ];

  Map<String, ui.Image> cachedImages = {};
  double gameTime = totalGameTime;
  bool isGameActive = true;

  int score = gameStartPoint;

  @override
  Future<void> onLoad() async {
    audio.init();

    await backtoCache();

    background = Background();
    add(background);

    pipe = Pipe();
    add(pipe);

    escalator = EscalatorManager();
    add(escalator);
    basketManager = BasketManager(
      cachedImages: cachedImages,
      patterns: patterns,
    );
    add(basketManager);

    borderOverlay = ScreenBorderOverlay();
    add(borderOverlay);

    await _ui();
  }

  Future<void> backtoCache() async {
    for (var item in networkImages) {
      final fruitName = item.keys.first;
      final imageUrl = item.values.first;

      final image = await networkAssets.load(imageUrl);

      cachedImages[fruitName] = image;
    }
  }

  Future<void> _ui() async {
    final scoreBox = PositionComponent(
      position: Vector2(10, 90),
      size: Vector2(160, 40),
    );

    final scoreBg = RectangleComponent(
      size: scoreBox.size,
      paint: Paint()..color = Colors.yellow,
    );

    scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(10, 8),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    scoreBox.add(scoreBg);
    scoreBox.add(scoreText);

    add(scoreBox);

    final timerBox = PositionComponent(
      position: Vector2(size.x / 2 - 80, 90),
      size: Vector2(160, 40),
    );

    final timerBg = RectangleComponent(
      size: timerBox.size,
      paint: Paint()..color = Colors.greenAccent,
    );

    timerText = TextComponent(
      text: 'Time: ${gameTime.toInt()}',
      position: Vector2(10, 8),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    timerBox.add(timerBg);
    timerBox.add(timerText);
    add(timerBox);

    gameOverText = TextComponent(
      text: 'Game Over!\nFinal Score: $score\nTap to restart',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void mismatchReduceTime() {
    gameTime -= 5;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameActive) {
      gameTime -= dt;

      timerText.text = 'Time: ${gameTime.toInt()}';

      if (gameTime <= 0) {
        _endGame();
      }
    }
  }

  void increaseScore(int points) {
    if (isGameActive) {
      score += points;
      scoreText.text = 'Score: $score';
    }
  }

  void _endGame() {
    isGameActive = false;
    gameTime = 0;
  }

  void _restartGame() {
    score = 0;
    gameTime = 60.0;
    isGameActive = true;

    scoreText.text = 'Score: $score';
    timerText.text = 'Time: ${gameTime.toInt()}';

    if (gameOverText.isMounted) {
      gameOverText.removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (!isGameActive) {
      _restartGame();
    }
  }
}
