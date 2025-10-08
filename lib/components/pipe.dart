import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_network_assets/flame_network_assets.dart';

class Pipe extends SpriteComponent with HasGameReference {
  final networkAssets = FlameNetworkImages();

  Pipe();

  @override
  FutureOr<void> onLoad() async {
    priority = 10;

    final image = await networkAssets.load(
      'https://cdn-icons-png.flaticon.com/128/258/258190.png',
    );

    sprite = Sprite(image);

    size = Vector2(50, 280);
    position = Vector2(0, game.size.y / 2 - 60);

    return super.onLoad();
  }
}
