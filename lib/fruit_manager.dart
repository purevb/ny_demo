// Updated FruitManager
import 'dart:math';

import 'package:flame/components.dart';
import 'package:ny/enums.dart';
import 'package:ny/fruit.dart';

class FruitManager extends Component with HasGameReference {
  double fruitRespawnTime = 0;
  double limit = 0;

  @override
  void update(double dt) {
    fruitRespawnTime += dt;
    if (fruitRespawnTime > 1 && limit < 100) {
      createFruit();
      fruitRespawnTime = 0;
    }
    super.update(dt);
  }

  void createFruit() {
    Random rand = Random();
    final fruitType = FruitEnums.values[rand.nextInt(FruitEnums.values.length)];
    final fruit = Fruit(
      fruitSize: Vector2(60, 60),
      fruitImage: "${fruitType.name}.png",
      fruitType: fruitType,
    );
    game.add(fruit);
    limit++;
  }
}
