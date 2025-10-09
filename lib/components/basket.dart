import 'dart:async';
import 'dart:ui' as ui;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Basket extends SpriteComponent with HasGameReference, CollisionCallbacks {
  final Vector2 basketSize;
  final Vector2 basketPosition;
  final ui.Image imgPath;
  final String basketType;

  Basket({
    required this.basketSize,
    required this.basketPosition,
    required this.imgPath,
    required this.basketType,
  });

  @override
  FutureOr<void> onLoad() async {
    sprite = Sprite(imgPath);
    size = basketSize;
    position = basketPosition;

    add(RectangleHitbox());
    return super.onLoad();
  }
}
