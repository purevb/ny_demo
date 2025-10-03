import 'dart:async';

import 'package:flame/components.dart';
import 'package:ny/components/escalator.dart';
import 'package:ny/components/escalator_circle.dart';
import 'package:ny/main.dart';

class EscalatorManager extends Component with HasGameReference<MyWorld> {
  Escalator? lastEscalator;
  EscalatorCircle? escalatorCircle;
  bool needsNewEscalator = false;

  @override
  FutureOr<void> onLoad() {
    priority = 8;
    escalatorCircle = EscalatorCircle();
    game.add(escalatorCircle!);
    createInitialEscalators();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    final escalators = game.children.whereType<Escalator>().toList();

    if (escalators.isNotEmpty) {
      final rightmostEscalator = escalators.reduce(
        (a, b) => a.position.x > b.position.x ? a : b,
      );

      if (rightmostEscalator.position.x + rightmostEscalator.size.x >
              game.size.x - 100 &&
          !needsNewEscalator) {
        needsNewEscalator = true;
      }

      if (needsNewEscalator) {
        final leftmostEscalator = escalators.reduce(
          (a, b) => a.position.x < b.position.x ? a : b,
        );

        if (leftmostEscalator.position.x > -10) {
          createEscalator();
          needsNewEscalator = false;
        }
      }
    }

    _cleanupEscalators();
    super.update(dt);
  }

  void createInitialEscalators() {
    final firstEscalator = Escalator(
      escalatorPosition: Vector2(-10, game.size.y / 2 + 10),
    );
    game.add(firstEscalator);
    lastEscalator = firstEscalator;
  }

  void createEscalator() {
    final escalator = Escalator(
      escalatorPosition: Vector2(-game.size.x, game.size.y / 2 + 10),
    );
    game.add(escalator);
    lastEscalator = escalator;
  }

  void _cleanupEscalators() {
    game.children.whereType<Escalator>().toList().forEach((escalator) {
      if (escalator.position.x > game.size.x + 100) {
        escalator.removeFromParent();
      }
    });
  }
}
