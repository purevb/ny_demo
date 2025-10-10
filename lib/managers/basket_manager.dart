import 'dart:async';
import 'dart:ui' as ui;
import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:ny/components/basket.dart';
import 'package:ny/constants.dart';
import 'package:ny/managers/fruit_manager.dart';

class BasketManager extends Component with HasGameReference {
  final Map<String, ui.Image> cachedImages;
  final List<List<String>> patterns;
  late FruitManager fruitManager;
  late Map<String, double> itemProbability;

  int _currentPatternIndex = 0;

  BasketManager({required this.cachedImages, required this.patterns});

  void calculatePatterns() {
    if (patterns.isEmpty) return;

    final getPattern = patterns.removeAt(0);

    itemProbability = {};

    final totalFruits = cachedImages.keys.length;

    double baseProbability = 1 / totalFruits;

    final counts = getPattern.groupFoldBy<String, int>(
      (f) => f,
      (prev, element) => (prev ?? 0) + 1,
    );

    double totalReduction = 0;
    counts.forEach((fruit, count) {
      double reduced = baseProbability - count * reduceProbability;
      itemProbability[fruit] = reduced;
      totalReduction += count * reduceProbability;
    });

    final otherFruits = cachedImages.keys
        .where((f) => !itemProbability.containsKey(f))
        .toList();

    double distributed = totalReduction / otherFruits.length;
    for (var fruit in otherFruits) {
      itemProbability[fruit] = baseProbability + distributed;
    }

    itemProbability.forEach((fruit, prob) {
      print("$fruit probability: $prob");
    });
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    generateBasket();
    calculatePatterns();
    fruitManager = FruitManager(
      cachedImages: cachedImages,
      probabilites: itemProbability,
    );
    add(fruitManager);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (children.whereType<Basket>().isEmpty) {
      _nextPattern();
      generateBasket();
      fruitManager.removeFromParent();
      fruitManager = FruitManager(
        cachedImages: cachedImages,
        probabilites: itemProbability,
      );
      add(fruitManager);
    }
  }

  void _nextPattern() {
    _currentPatternIndex++;
    if (_currentPatternIndex >= patterns.length) {
      _currentPatternIndex = 0;
    }
  }

  void generateBasket() {
    if (cachedImages.isEmpty || patterns.isEmpty) return;

    final pattern = patterns[_currentPatternIndex];

    for (int j = 0; j < pattern.length; j++) {
      final fruitType = pattern[j % pattern.length];
      final fruitImage = cachedImages[fruitType];
      if (fruitImage == null) continue;

      final basket = Basket(
        basketSize: Vector2(60, 60),
        basketPosition: Vector2((j + 1) * (game.size.x / 5), game.size.y - 100),
        imgPath: fruitImage,
        basketType: fruitType,
      );

      add(basket);
    }
  }

  void regenerateBaskets() {
    removeAll(children.whereType<Basket>().toList());
    _nextPattern();
    generateBasket();
  }
}
