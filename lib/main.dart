import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:ny/audio_manager.dart';
import 'package:ny/basket.dart';
import 'package:ny/basket_manager.dart';
import 'package:ny/fruit_manager.dart';
import 'package:ny/ny_overlay.dart';
import 'package:ny/pipe.dart';

void main() {
  runApp(GameWidget(game: MyWorld()));
}

class MyWorld extends FlameGame with TapCallbacks, HasCollisionDetection {
  late Pipe pipe;
  late FruitManager fruitManager;
  late BasketManager basketManager;

  late TextComponent scoreText;
  late TextComponent timerText;
  late TextComponent gameOverText;
  late ScreenBorderOverlay borderOverlay;

  final audio = NYAudioManager();

  int score = 0;
  double gameTime = 60.0;
  bool isGameActive = true;

  @override
  Future<void> onLoad() async {
    audio.init();

    final borderOverlay = ScreenBorderOverlay();
    add(borderOverlay);
    pipe = Pipe();
    add(pipe);

    fruitManager = FruitManager();
    add(fruitManager);

    basketManager = BasketManager();
    add(basketManager);

    await _ui();
  }

  Future<void> _ui() async {
    scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(10, 90),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);

    timerText = TextComponent(
      text: 'Time: ${gameTime.toInt()}',
      position: Vector2(size.x / 2 - 50, 90),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(timerText);

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
