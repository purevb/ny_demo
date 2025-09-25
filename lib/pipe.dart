import 'dart:async';

import 'package:flame/components.dart';

class Pipe extends SpriteComponent with HasGameReference {
  Pipe();
  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load("pipes.png");
    size = Vector2(50, 150);
    position = Vector2(0, game.size.y / 2);
    return super.onLoad();
  }
}
