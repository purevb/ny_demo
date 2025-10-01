import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:ny/components/fruit.dart';
import 'package:ny/constants.dart';
import 'package:ny/enums/enums.dart';

class FruitManager extends Component with HasGameReference {
  double fruitRespawnTime = 0;
  Random rand = Random();
  bool converter = false;
  late List<Vector2> fruitsDefaultPosition;

  @override
  FutureOr<void> onLoad() {
    priority = 9;
    return super.onLoad();
  }

  @override
  Future<void> onMount() async {
    super.onMount();

    fruitsDefaultPosition = [
      Vector2(50, game.size.y / 2),
      Vector2(50, game.size.y / 2 + 35),
      Vector2(50, game.size.y / 2 + 70),
    ];
  }

  @override
  void update(double dt) {
    fruitRespawnTime += dt;
    if (fruitRespawnTime > 0.5) {
      converter = !converter;
      createFruitsOnAllLines();
      fruitRespawnTime = 0;
    }

    _cleanupFruits();

    super.update(dt);
  }

  void createFruitsOnAllLines() {
    final fruitImg = FruitEnums.values[rand.nextInt(FruitEnums.values.length)];

    for (int i = 0; i < 3; i++) {
      if (converter) {
        if (i % 2 == 0) {
          final fruit = Fruit(
            fruitImage: "${fruitImg.name}.png",
            fruitSize: fruitSize,
            fruitType: fruitImg,
            fruitPositon: fruitsDefaultPosition[i],
          );
          game.add(fruit);
        }
      } else {
        if (i % 2 == 1) {
          final fruit = Fruit(
            fruitImage: "${fruitImg.name}.png",
            fruitSize: fruitSize,
            fruitType: fruitImg,
            fruitPositon: fruitsDefaultPosition[i],
          );
          game.add(fruit);
        }
      }
    }
  }

  void _cleanupFruits() {
    final fruits = children.whereType<Fruit>().toList();

    for (final fruit in fruits) {
      if (fruit.position.x > game.size.x + fruit.size.x) {
        fruit.removeFromParent();
      }
    }
  }
}
