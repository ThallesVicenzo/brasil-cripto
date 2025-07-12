import 'dart:math';
import 'package:flutter/material.dart';

class FallingCoinsBackground extends StatefulWidget {
  final Widget child;
  final int numberOfCoins;
  final Duration animationDuration;

  const FallingCoinsBackground({
    super.key,
    required this.child,
    this.numberOfCoins = 15,
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<FallingCoinsBackground> createState() => _FallingCoinsBackgroundState();
}

class _FallingCoinsBackgroundState extends State<FallingCoinsBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<CoinData> _coins;
  final Random _random = Random();
  double _screenWidth = 0;
  double _screenHeight = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);

    final newScreenWidth = mediaQuery.size.width;
    final newScreenHeight = mediaQuery.size.height;

    if (_screenWidth != newScreenWidth || _screenHeight != newScreenHeight) {
      _screenWidth = newScreenWidth;
      _screenHeight = newScreenHeight;
    }

    if (!_isInitialized) {
      _initializeAnimations();
      _isInitialized = true;
    }
  }

  void _initializeAnimations() {
    _controllers = [];
    _animations = [];
    _coins = [];

    for (int i = 0; i < widget.numberOfCoins; i++) {
      final baseDuration = widget.animationDuration.inMilliseconds;
      final variableDuration = baseDuration + _random.nextInt(1500);

      final controller = AnimationController(
        duration: Duration(milliseconds: variableDuration),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: -150.0,
        end: 1200.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

      final coin = CoinData(
        x: _random.nextDouble(),
        size: 20 + _random.nextDouble() * 20,
        coinType: CoinType.values[_random.nextInt(CoinType.values.length)],
        rotationSpeed: 0.3 + _random.nextDouble() * 1.0,
        horizontalDrift: (_random.nextDouble() - 0.5) * 0.1,
      );

      _controllers.add(controller);
      _animations.add(animation);
      _coins.add(coin);

      final delay = _random.nextInt(widget.animationDuration.inMilliseconds);
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          _startCoinAnimation(i);
        }
      });
    }
  }

  void _startCoinAnimation(int index) {
    _controllers[index].forward().then((_) {
      if (mounted) {
        _controllers[index].reset();
        _coins[index] = _coins[index].copyWith(
          x: _random.nextDouble(),
          horizontalDrift: (_random.nextDouble() - 0.5) * 0.1,
        );
        final delay = 200 + _random.nextInt(800);
        Future.delayed(Duration(milliseconds: delay), () {
          if (mounted) {
            _startCoinAnimation(index);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const ColoredBox(color: Colors.black, child: SizedBox.expand());
    }

    return Stack(
      children: [
        const ColoredBox(color: Colors.black, child: SizedBox.expand()),
        ...List.generate(widget.numberOfCoins, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              final coin = _coins[index];
              final animationValue = _animations[index].value;

              final baseX = coin.x * _screenWidth;
              final drift = coin.horizontalDrift * animationValue;
              final finalX = baseX + drift;

              if (animationValue < -200) {
                return const SizedBox.shrink();
              }

              if (animationValue > _screenHeight + 100) {
                return const SizedBox.shrink();
              }

              return Positioned(
                left: finalX.clamp(0.0, _screenWidth - coin.size),
                top: animationValue,
                child: Transform.rotate(
                  angle: animationValue * coin.rotationSpeed * 0.005,
                  child: child!,
                ),
              );
            },
            child: _buildCoin(_coins[index]),
          );
        }),
        widget.child,
      ],
    );
  }

  Widget _buildCoin(CoinData coin) {
    final colors = coin.coinType.colors;
    final symbol = coin.coinType.symbol;

    return RepaintBoundary(
      child: Container(
        width: coin.size,
        height: coin.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: colors,
            center: const Alignment(-0.3, -0.3),
            stops: const [0.0, 0.7, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            symbol,
            style: TextStyle(
              color: Colors.white,
              fontSize: coin.size * 0.4,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                ),
                Shadow(
                  color: colors.first.withValues(alpha: 0.5),
                  blurRadius: 6,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CoinData {
  final double x;
  final double size;
  final CoinType coinType;
  final double rotationSpeed;
  final double horizontalDrift;

  CoinData({
    required this.x,
    required this.size,
    required this.coinType,
    required this.rotationSpeed,
    this.horizontalDrift = 0.0,
  });

  CoinData copyWith({
    double? x,
    double? size,
    CoinType? coinType,
    double? rotationSpeed,
    double? horizontalDrift,
  }) {
    return CoinData(
      x: x ?? this.x,
      size: size ?? this.size,
      coinType: coinType ?? this.coinType,
      rotationSpeed: rotationSpeed ?? this.rotationSpeed,
      horizontalDrift: horizontalDrift ?? this.horizontalDrift,
    );
  }
}

enum CoinType {
  bitcoin,
  ethereum,
  tether,
  usd,
  cardano,
  solana,
  dogecoin,
  polygon,
  chainlink;

  List<Color> get colors {
    switch (this) {
      case CoinType.bitcoin:
        return [
          const Color(0xFFf7931a),
          const Color(0xFFe6850e),
          const Color(0xFFd4730a),
        ];
      case CoinType.ethereum:
        return [
          const Color(0xFF627eea),
          const Color(0xFF4c6bdb),
          const Color(0xFF3a52cc),
        ];
      case CoinType.tether:
        return [
          const Color(0xFF26a17b),
          const Color(0xFF1d8a63),
          const Color(0xFF15714b),
        ];
      case CoinType.usd:
        return [
          const Color(0xFF2e7bd6),
          const Color(0xFF1e5ba3),
          const Color(0xFF164270),
        ];
      case CoinType.cardano:
        return [
          const Color(0xFF0033ad),
          const Color(0xFF002287),
          const Color(0xFF001861),
        ];
      case CoinType.solana:
        return [
          const Color(0xFF9945ff),
          const Color(0xFF8a3fd9),
          const Color(0xFF7b39b3),
        ];
      case CoinType.dogecoin:
        return [
          const Color(0xFFc2a633),
          const Color(0xFFb89d2f),
          const Color(0xFFae942a),
        ];
      case CoinType.polygon:
        return [
          const Color(0xFF8247e5),
          const Color(0xFF7341d9),
          const Color(0xFF643bcd),
        ];
      case CoinType.chainlink:
        return [
          const Color(0xFF375bd2),
          const Color(0xFF2d4bb8),
          const Color(0xFF243b9e),
        ];
    }
  }

  String get symbol {
    switch (this) {
      case CoinType.bitcoin:
        return '₿';
      case CoinType.ethereum:
        return 'Ξ';
      case CoinType.tether:
        return '₮';
      case CoinType.usd:
        return '\$';
      case CoinType.cardano:
        return '₳';
      case CoinType.solana:
        return 'S';
      case CoinType.dogecoin:
        return 'Ð';
      case CoinType.polygon:
        return '⬟';
      case CoinType.chainlink:
        return '⬢';
    }
  }
}
