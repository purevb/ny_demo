import 'dart:math';
import 'package:flame/components.dart';
import 'package:ny/enums.dart';
import 'package:ny/fruit.dart';

class FruitManager extends Component with HasGameReference {
  double fruitRespawnTime = 0;
  double limit = 0;
  List<int> threeLine = [0, 70, -70];

  @override
  void update(double dt) {
    fruitRespawnTime += dt;
    if (fruitRespawnTime > 2 && limit < 200) {
      createFruitsOnAllLines();
      fruitRespawnTime = 0;
    }
    super.update(dt);
  }

  void createFruitsOnAllLines() {
    Random rand = Random();

    for (int lineOffset in threeLine) {
      final fruitType =
          FruitEnums.values[rand.nextInt(FruitEnums.values.length)];
      final fruit = Fruit(
        fruitSize: Vector2(60, 60),
        fruitImage: "${fruitType.name}.png",
        fruitType: fruitType,
      );

      fruit.setSpecificLine(lineOffset);

      game.add(fruit);
      limit++;
    }
  }

  void createFruitOnSpecificLine(int lineOffset) {
    Random rand = Random();
    final fruitType = FruitEnums.values[rand.nextInt(FruitEnums.values.length)];
    final fruit = Fruit(
      fruitSize: Vector2(60, 60),
      fruitImage: "${fruitType.name}.png",
      fruitType: fruitType,
    );

    fruit.setSpecificLine(lineOffset);
    game.add(fruit);
    limit++;
  }
}
