// background.dart
import 'dart:async';
import 'package:flame/components.dart';

class Background extends SpriteComponent with HasGameReference {
  Background();

  @override
  Future<void> onLoad() async {
    size = game.size;
    sprite = await Sprite.load("bg.png");
    position = Vector2.zero();
    return super.onLoad();
  }
}
