import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:ny/components/fruit.dart';
import 'package:ny/constants.dart';

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
      Vector2(00, game.size.y / 2),
      Vector2(00, game.size.y / 2 + 35),
      Vector2(0, game.size.y / 2 + 70),
    ];
  }

  @override
  void update(double dt) {
    fruitRespawnTime += dt;
    if (fruitRespawnTime > fruitRegenarateTiime) {
      converter = !converter;
      createFruitsOnAllLines();
      fruitRespawnTime = 0;
    }

    _cleanupFruits();

    super.update(dt);
  }

  void createFruitsOnAllLines() {
    for (int i = 0; i < 3; i++) {
      bool shouldAdd = false;

      if (converter) {
        if (i % 2 == 0) shouldAdd = true;
      } else {
        if (i % 2 == 1) shouldAdd = true;
      }

      if (shouldAdd && fruitQueue.isNotEmpty) {
        final fruitQ = fruitQueue.removeAt(0);

        final fruit = Fruit(
          fruitImage: "${fruitQ.name}.png",
          fruitSize: fruitSize,
          fruitType: fruitQ,
          fruitPositon: fruitsDefaultPosition[i],
        );
        game.add(fruit);
      }
    }
  }

  void _cleanupFruits() {
    final fruits = game.children.query<Fruit>().toList();
    int removed = 0;
    for (final fruit in fruits) {
      if (fruit.position.x > game.size.x + fruit.size.x) {
        fruit.removeFromParent();
        removed++;
      }
    }
    if (fruits.length - removed > 20) {
      final excess = fruits.length - removed - 20;
      for (int i = 0; i < excess; i++) {
        fruits[i].removeFromParent();
      }
    }
  }
}
