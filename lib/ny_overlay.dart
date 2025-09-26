import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class ScreenBorderOverlay extends RectangleComponent with HasGameReference {
  static const double borderWidth = 8.0;
  static const double displayDuration = 1.0;

  double _currentOpacity = 0.0;
  double _remainingTime = 0.0;
  Color _baseColor = Colors.transparent;

  ScreenBorderOverlay()
    : super(
        paint: Paint()
          ..color = Colors.transparent
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );

  @override
  FutureOr<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();

    priority = 1000;

    return super.onLoad();
  }

  void showSuccessBorder() {
    _showBorder(Colors.green);
  }

  void showErrorBorder() {
    _showBorder(Colors.red);
  }

  void _showBorder(Color color) {
    _baseColor = color;
    _currentOpacity = 0.8;
    _remainingTime = displayDuration;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_remainingTime > 0) {
      _remainingTime -= dt;

      if (_remainingTime <= 0) {
        _currentOpacity = 0;
        _remainingTime = 0;
      } else {
        double fadeStartTime = displayDuration * 0.3;

        if (_remainingTime <= fadeStartTime) {
          _currentOpacity = (_remainingTime / fadeStartTime) * 0.8;
        } else {
          _currentOpacity = 0.8;
        }
      }

      paint.color = _baseColor.withOpacity(_currentOpacity);
    }
  }

  @override
  void render(Canvas canvas) {
    if (_currentOpacity > 0) {
      final rect = Rect.fromLTWH(0, 0, size.x, size.y);
      canvas.drawRect(rect, paint);
    }
  }
}

extension GameBorderExtension on FlameGame {
  ScreenBorderOverlay? get _borderOverlay {
    try {
      return children.query<ScreenBorderOverlay>().first;
    } catch (e) {
      return null;
    }
  }

  void showSuccessBorder() {
    _borderOverlay?.showSuccessBorder();
  }

  void showErrorBorder() {
    _borderOverlay?.showErrorBorder();
  }
}
