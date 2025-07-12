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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = [];
    _animations = [];
    _coins = [];

    for (int i = 0; i < widget.numberOfCoins; i++) {
      final controller = AnimationController(
        duration: Duration(
          milliseconds:
              widget.animationDuration.inMilliseconds + _random.nextInt(2000),
        ),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: -100,
        end: 1000,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));

      final coin = CoinData(
        x: _random.nextDouble(),
        size: 25 + _random.nextDouble() * 15,
        coinType: CoinType.values[_random.nextInt(CoinType.values.length)],
        rotationSpeed: 0.5 + _random.nextDouble() * 1.5,
      );

      _controllers.add(controller);
      _animations.add(animation);
      _coins.add(coin);

      Future.delayed(Duration(milliseconds: _random.nextInt(2000)), () {
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
        _coins[index] = _coins[index].copyWith(x: _random.nextDouble());
        Future.delayed(Duration(milliseconds: _random.nextInt(1000)), () {
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
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
        ),
        ...List.generate(widget.numberOfCoins, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Positioned(
                left: _coins[index].x * MediaQuery.of(context).size.width,
                top: _animations[index].value,
                child: Transform.rotate(
                  angle:
                      _animations[index].value *
                      _coins[index].rotationSpeed *
                      0.01,
                  child: _buildCoin(_coins[index]),
                ),
              );
            },
          );
        }),
        widget.child,
      ],
    );
  }

  Widget _buildCoin(CoinData coin) {
    return Container(
      width: coin.size,
      height: coin.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: coin.coinType.colors,
          center: const Alignment(-0.3, -0.3),
          stops: const [0.0, 0.7, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: coin.coinType.colors.first.withValues(alpha: 0.4),
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
          coin.coinType.symbol,
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
                color: coin.coinType.colors.first.withValues(alpha: 0.5),
                blurRadius: 6,
                offset: const Offset(0, 0),
              ),
            ],
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

  CoinData({
    required this.x,
    required this.size,
    required this.coinType,
    required this.rotationSpeed,
  });

  CoinData copyWith({
    double? x,
    double? size,
    CoinType? coinType,
    double? rotationSpeed,
  }) {
    return CoinData(
      x: x ?? this.x,
      size: size ?? this.size,
      coinType: coinType ?? this.coinType,
      rotationSpeed: rotationSpeed ?? this.rotationSpeed,
    );
  }
}

enum CoinType {
  bitcoin,
  ethereum,
  tether,
  usd,
  cardano;

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
    }
  }
}
