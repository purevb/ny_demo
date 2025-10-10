import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:ny/components/fruit.dart';
import 'package:ny/constants.dart';

class FruitManager extends Component with HasGameReference {
  Map<String, ui.Image> cachedImages;
  Map<String, double> probabilities;

  FruitManager({
    required this.cachedImages,
    required Map<String, double> probabilites,
  }) : probabilities = probabilites;

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
      Vector2(0, game.size.y / 2),
      Vector2(0, game.size.y / 2 + 35),
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

  String _selectFruitByProbability() {
    if (probabilities.isEmpty) {
      final fruitTypes = cachedImages.keys.toList();
      return fruitTypes[rand.nextInt(fruitTypes.length)];
    }

    double totalProbability = probabilities.values.reduce((a, b) => a + b);

    double randomValue = rand.nextDouble() * totalProbability;

    double cumulative = 0.0;
    for (var entry in probabilities.entries) {
      cumulative += entry.value;
      if (randomValue <= cumulative) {
        return entry.key;
      }
    }

    return probabilities.keys.first;
  }

  void createFruitsOnAllLines() {
    if (cachedImages.isEmpty) return;

    for (int i = 0; i < 3; i++) {
      bool shouldAdd = false;

      if (converter) {
        if (i % 2 == 0) shouldAdd = true;
      } else {
        if (i % 2 == 1) shouldAdd = true;
      }

      if (shouldAdd) {
        final randomType = _selectFruitByProbability();
        final fruitImage = cachedImages[randomType]!;

        final fruit = Fruit(
          fruitImage: fruitImage,
          fruitSize: fruitSize,
          fruitType: randomType,
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
