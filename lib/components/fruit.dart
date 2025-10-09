import 'dart:async';
import 'dart:ui' as ui;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:ny/audio/audio_manager.dart';
import 'package:ny/components/basket.dart';
import 'package:ny/constants.dart';
import 'package:ny/main.dart';
import 'package:ny/overlay/ny_overlay.dart';

class Fruit extends SpriteComponent
    with HasGameReference, DragCallbacks, CollisionCallbacks {
  final ui.Image fruitImage;
  final Vector2 fruitSize;
  final String fruitType;
  final Vector2 fruitPositon;

  bool _isDragging = false;
  bool _shouldRemove = false;
  bool _isRemoving = false;
  bool _gestureBlocked = false;
  double _elapsedTime = 0;

  late Vector2 _initialPosition;
  late Vector2 grabbedPosition;
  final audio = NYAudioManager();

  Fruit({
    required this.fruitImage,
    required this.fruitSize,
    required this.fruitType,
    required this.fruitPositon,
  });

  List<int> threeLine = [0, 70, -70];

  @override
  FutureOr<void> onLoad() async {
    sprite = Sprite(fruitImage);
    _initialPosition = fruitPositon;
    position = _initialPosition.clone();
    size = fruitSize;
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (_isRemoving || _gestureBlocked) return;

    grabbedPosition = position.clone();
    _elapsedTime = 0;

    super.onDragStart(event);
    _isDragging = true;
    priority = 10;
  }

  void dragEndAndMismatch() {
    _isDragging = false;
    _gestureBlocked = true;
    priority = 0;

    position = Vector2(
      grabbedPosition.x + _elapsedTime * defaultGameSpeed,
      _initialPosition.y,
    );

    _elapsedTime = 0;

    Future.delayed(Duration(milliseconds: 1), () {
      _gestureBlocked = false;
    });
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (_isRemoving || _gestureBlocked) return;

    super.onDragCancel(event);

    position = Vector2(
      grabbedPosition.x + _elapsedTime * defaultGameSpeed,
      _initialPosition.y,
    );

    _isDragging = false;
    _elapsedTime = 0;
    priority = 0;

    _gestureBlocked = true;
    Future.delayed(Duration(milliseconds: 1), () {
      _gestureBlocked = false;
    });
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
  void update(double dt) {
    if (_shouldRemove && !_isRemoving) {
      _safeRemove();
      return;
    }

    if (!_isDragging && !_isRemoving && !_gestureBlocked) {
      position.x += dt * defaultGameSpeed;
    }

    if (_isDragging) {
      _elapsedTime += dt;
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
          _playSound(isSucces: true);
          game.showSuccessBorder();
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
          _playSound(isSucces: false);
          game.showErrorBorder();
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
      debugPrint('Failed to play success sound: $e');
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
