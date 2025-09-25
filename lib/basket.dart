import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:ny/enums.dart';

class Basket extends SpriteComponent with HasGameReference, CollisionCallbacks {
  final Vector2 basketSize;
  final Vector2 basketPosition;
  final String imgPath;
  final FruitEnums basketType;

  Basket({
    required this.basketSize,
    required this.basketPosition,
    required this.imgPath,
    required this.basketType,
  });

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load(imgPath);
    size = basketSize;
    position = basketPosition;

    add(RectangleHitbox());
    return super.onLoad();
  }
}
