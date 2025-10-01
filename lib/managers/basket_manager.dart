import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:ny/components/basket.dart';
import 'package:ny/enums/enums.dart';

class BasketManager extends Component with HasGameReference {
  BasketManager();

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    generateBasket();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final basketCount = children.whereType<Basket>().length;
    if (basketCount == 0) {
      generateBasket();
    }
  }

  void generateBasket() {
    Random rand = Random();
    removeAll(children.whereType<Basket>());

    for (int i = 0; i < 4; i++) {
      final fruitType =
          FruitEnums.values[rand.nextInt(FruitEnums.values.length)];

      final basket = Basket(
        basketSize: Vector2(60, 60),
        basketPosition: Vector2((i + 1) * (game.size.x / 5), game.size.y - 100),
        imgPath: "${fruitType.name}.png",
        basketType: fruitType,
      );
      add(basket);
    }
  }

  void regenerateBaskets() {
    generateBasket();
  }
}
