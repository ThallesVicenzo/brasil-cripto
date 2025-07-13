import 'package:flutter/material.dart';

class CoinAnimationModel {
  final double x;
  final double size;
  final CoinType coinType;
  final double rotationSpeed;
  final double horizontalDrift;

  const CoinAnimationModel({
    required this.x,
    required this.size,
    required this.coinType,
    required this.rotationSpeed,
    this.horizontalDrift = 0.0,
  });

  CoinAnimationModel copyWith({
    double? x,
    double? size,
    CoinType? coinType,
    double? rotationSpeed,
    double? horizontalDrift,
  }) {
    return CoinAnimationModel(
      x: x ?? this.x,
      size: size ?? this.size,
      coinType: coinType ?? this.coinType,
      rotationSpeed: rotationSpeed ?? this.rotationSpeed,
      horizontalDrift: horizontalDrift ?? this.horizontalDrift,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoinAnimationModel &&
        other.x == x &&
        other.size == size &&
        other.coinType == coinType &&
        other.rotationSpeed == rotationSpeed &&
        other.horizontalDrift == horizontalDrift;
  }

  @override
  int get hashCode {
    return Object.hash(x, size, coinType, rotationSpeed, horizontalDrift);
  }

  @override
  String toString() {
    return 'CoinAnimationModel(x: $x, size: $size, coinType: $coinType, rotationSpeed: $rotationSpeed, horizontalDrift: $horizontalDrift)';
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
