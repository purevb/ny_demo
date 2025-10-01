import 'dart:async';
import 'package:flame/components.dart';
import 'package:ny/constants.dart';

class Escalator extends SpriteComponent with HasGameReference {
  final Vector2 escalatorPosition;

  Escalator({required this.escalatorPosition})
    : super(position: escalatorPosition);

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load("escalator.png");
    size = Vector2(game.size.x, 160);
    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size.x = size.x;
  }

  @override
  void update(double dt) {
    position.x += defaultGameSpeed * dt;
    if (position.x > game.size.x) {
      removeFromParent();
    }
    super.update(dt);
  }
}
