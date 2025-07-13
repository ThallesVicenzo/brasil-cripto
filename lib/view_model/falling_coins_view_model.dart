import 'dart:async';
import 'dart:math';
import 'package:brasil_cripto/model/models/coin_animation_model.dart';
import 'package:flutter/material.dart';

class FallingCoinsViewModel extends ChangeNotifier {
  final Random _random = Random();
  bool _disposed = false;

  List<AnimationController> _controllers = [];
  List<Animation<double>> _animations = [];
  List<CoinAnimationModel> _coins = [];
  List<Timer> _timers = [];
  double _screenWidth = 0;
  double _screenHeight = 0;
  bool _isInitialized = false;
  bool _isKeyboardVisible = false;

  // Getters
  List<AnimationController> get controllers => _controllers;
  List<Animation<double>> get animations => _animations;
  List<CoinAnimationModel> get coins => _coins;
  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;
  bool get isInitialized => _isInitialized;
  bool get isKeyboardVisible => _isKeyboardVisible;

  int get activeCoinsCount {
    if (_coins.isEmpty) return 0;

    if (_isKeyboardVisible) {
      return (_coins.length * 0.6).round();
    }
    return _coins.length;
  }

  void updateScreenDimensions(double width, double height) {
    if (_screenWidth != width || _screenHeight != height) {
      _screenWidth = width;
      _screenHeight = height;
      _safeNotifyListeners();
    }
  }

  void initializeAnimations({
    required TickerProvider vsync,
    required int numberOfCoins,
    required Duration animationDuration,
  }) {
    if (_isInitialized) return;

    _controllers = [];
    _animations = [];
    _coins = [];
    _timers = [];

    for (int i = 0; i < numberOfCoins; i++) {
      final baseDuration = animationDuration.inMilliseconds;
      final variableDuration = baseDuration + _random.nextInt(1500);

      final controller = AnimationController(
        duration: Duration(milliseconds: variableDuration),
        vsync: vsync,
      );

      final animation = Tween<double>(
        begin: -150.0,
        end: 1200.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

      final coin = CoinAnimationModel(
        x: _random.nextDouble(),
        size: 20 + _random.nextDouble() * 20,
        coinType: CoinType.values[_random.nextInt(CoinType.values.length)],
        rotationSpeed: 0.3 + _random.nextDouble() * 1.0,
        horizontalDrift: (_random.nextDouble() - 0.5) * 0.1,
      );

      _controllers.add(controller);
      _animations.add(animation);
      _coins.add(coin);

      final delay = _random.nextInt(animationDuration.inMilliseconds);
      final timer = Timer(Duration(milliseconds: delay), () {
        if (!_disposed) {
          startCoinAnimation(i);
        }
      });
      _timers.add(timer);
    }

    _isInitialized = true;
    _safeNotifyListeners();
  }

  void startCoinAnimation(int index) {
    if (_disposed || index >= _controllers.length) return;

    _controllers[index].forward().then((_) {
      if (!_disposed && index < _coins.length) {
        _controllers[index].reset();
        _coins[index] = _coins[index].copyWith(
          x: _random.nextDouble(),
          horizontalDrift: (_random.nextDouble() - 0.5) * 0.1,
        );
        final delay = 200 + _random.nextInt(800);
        final timer = Timer(Duration(milliseconds: delay), () {
          if (!_disposed) {
            startCoinAnimation(index);
          }
        });
        _timers.add(timer);
      }
    });
  }

  CoinPosition calculateCoinPosition(int index) {
    if (_disposed ||
        index < 0 ||
        index >= _coins.length ||
        index >= _animations.length) {
      return const CoinPosition(x: 0, y: 0, isVisible: false);
    }

    final coin = _coins[index];
    final animationValue = _animations[index].value;

    final baseX = coin.x * _screenWidth;
    final drift = coin.horizontalDrift * animationValue;
    final finalX = baseX + drift;

    final isVisible =
        animationValue >= -200 && animationValue <= _screenHeight + 100;

    return CoinPosition(
      x: finalX.clamp(0.0, _screenWidth - coin.size),
      y: animationValue,
      isVisible: isVisible,
      rotation: animationValue * coin.rotationSpeed * 0.005,
    );
  }

  void setKeyboardVisibility(bool isVisible) {
    if (_isKeyboardVisible != isVisible) {
      _isKeyboardVisible = isVisible;

      if (isVisible) {
        _optimizeForKeyboard();
      } else {
        _resumeAllAnimations();
      }

      _safeNotifyListeners();
    }
  }

  void _resumeAllAnimations() {
    Timer(const Duration(milliseconds: 150), () {
      if (!_disposed) {
        for (int i = 0; i < _controllers.length; i++) {
          if (!_controllers[i].isAnimating) {
            final staggeredDelay = i * 50;
            Timer(Duration(milliseconds: staggeredDelay), () {
              if (!_disposed) {
                startCoinAnimation(i);
              }
            });
          }
        }
      }
    });
  }

  void _optimizeForKeyboard() {
    if (!_isKeyboardVisible || _coins.isEmpty || _controllers.isEmpty) return;

    final activeCount = activeCoinsCount;

    for (int i = activeCount; i < _controllers.length; i++) {
      if (_controllers[i].isAnimating) {
        _controllers[i].stop();
      }
    }
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_disposed) return;

    _disposed = true;

    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    for (var controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _animations.clear();
    _coins.clear();
    super.dispose();
  }
}

class CoinPosition {
  final double x;
  final double y;
  final bool isVisible;
  final double rotation;

  const CoinPosition({
    required this.x,
    required this.y,
    required this.isVisible,
    this.rotation = 0.0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoinPosition &&
        other.x == x &&
        other.y == y &&
        other.isVisible == isVisible &&
        other.rotation == rotation;
  }

  @override
  int get hashCode {
    return Object.hash(x, y, isVisible, rotation);
  }

  @override
  String toString() {
    return 'CoinPosition(x: $x, y: $y, isVisible: $isVisible, rotation: $rotation)';
  }
}
