import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:ny/audio/audio_manager.dart';
import 'package:ny/components/basket.dart';
import 'package:ny/constants.dart';
import 'package:ny/enums/enums.dart';
import 'package:ny/main.dart';
import 'package:ny/overlay/ny_overlay.dart';

class Fruit extends SpriteComponent
    with HasGameReference, DragCallbacks, CollisionCallbacks {
  final String fruitImage;
  final Vector2 fruitSize;
  final FruitEnums fruitType;
  final Vector2 fruitPositon;

  bool _isDragging = false;
  bool _shouldRemove = false;
  bool _isRemoving = false;
  bool _gestureBlocked = false;
  double _elapsedTime = 0;
  late Vector2 _initialPosition;
  int? _specificLineOffset;

  final audio = NYAudioManager();

  Fruit({
    required this.fruitImage,
    required this.fruitSize,
    required this.fruitType,
    required this.fruitPositon,
  });

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load(fruitImage);
    _initialPosition = fruitPositon;
    position = _initialPosition.clone();
    size = fruitSize;
    add(RectangleHitbox());
    return super.onLoad();
  }

  void setSpecificLine(int lineOffset) {
    _specificLineOffset = lineOffset;
  }

  void dragEndAndMismatch() {
    _isDragging = false;
    _gestureBlocked = true;
    priority = 0;
    position = Vector2(
      _initialPosition.x + _elapsedTime * 112,
      _initialPosition.y,
    );

    Future.delayed(Duration(milliseconds: 000), () {
      _gestureBlocked = false;
    });
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (_isRemoving || _gestureBlocked) return;

    super.onDragStart(event);
    _isDragging = true;
    priority = 10;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (_isRemoving || _gestureBlocked) return;

    super.onDragEnd(event);

    if (_isDragging) {
      dragEndAndMismatch();
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_isRemoving || _gestureBlocked || !_isDragging) return;

    position += event.localDelta;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (_isRemoving || _gestureBlocked) return;

    super.onDragCancel(event);
    _isDragging = false;
    priority = 0;
  }

  @override
  void update(double dt) {
    if (_shouldRemove && !_isRemoving) {
      _safeRemove();
      return;
    }

    if (!_isDragging && !_isRemoving && !_gestureBlocked) {
      _elapsedTime += dt;
      position.x += dt * defaultGameSpeed;
    }
    super.update(dt);
  }

  void _safeRemove() {
    _isRemoving = true;
    _gestureBlocked = true;

    if (_isDragging) {
      _isDragging = false;
      priority = 0;
    }

    removeFromParent();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Basket && !_shouldRemove && !_isRemoving) {
      if (fruitType == other.basketType) {
        if (game is MyWorld) {
          (game as MyWorld).increaseScore(10);

          game.showSuccessBorder();

          _playSound(isSucces: true);
        }

        _shouldRemove = true;
        other.add(
          ScaleEffect.to(
            Vector2.zero(),
            EffectController(duration: 0.3),
            onComplete: () {
              other.removeFromParent();
            },
          ),
        );
      } else {
        if (game is MyWorld) {
          (game as MyWorld).mismatchReduceTime();

          game.showErrorBorder();

          _playSound(isSucces: false);
        }

        other.add(
          MoveEffect.by(
            Vector2(10, 0),
            EffectController(
              duration: 0.05,
              reverseDuration: 0.05,
              repeatCount: 3,
            ),
          ),
        );
        dragEndAndMismatch();
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  void _playSound({required bool isSucces}) async {
    try {
      if (audio.isInitialized) {
        if (isSucces) {
          await audio.playSound("assets/audio/success.mp3");
        } else {
          await audio.playSound("assets/audio/wrong.mp3");
        }
      }
    } catch (e) {
      print('Failed to play success sound: $e');
    }
  }

  @override
  void onRemove() {
    _isRemoving = true;
    _isDragging = false;
    _gestureBlocked = true;
    super.onRemove();
  }
}
