import 'dart:async';

import 'package:flame/components.dart';

class EscalatorCircle extends SpriteComponent with HasGameReference {
  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load("escalator_circle.png");
    size = Vector2(game.size.x, 60);
    position = Vector2(0, game.size.y / 2 + 130);
    return super.onLoad();
  }
}
