import 'package:brasil_cripto/model/models/coin_animation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoinAnimationModel Tests', () {
    test('should create CoinAnimationModel with correct values', () {
      // Arrange & Act
      const model = CoinAnimationModel(
        x: 0.5,
        size: 40.0,
        coinType: CoinType.bitcoin,
        rotationSpeed: 1.0,
        horizontalDrift: 0.1,
      );

      // Assert
      expect(model.x, equals(0.5));
      expect(model.size, equals(40.0));
      expect(model.coinType, equals(CoinType.bitcoin));
      expect(model.rotationSpeed, equals(1.0));
      expect(model.horizontalDrift, equals(0.1));
    });

    test('should have default horizontalDrift value', () {
      // Arrange & Act
      const model = CoinAnimationModel(
        x: 0.5,
        size: 40.0,
        coinType: CoinType.ethereum,
        rotationSpeed: 1.0,
      );

      // Assert
      expect(model.horizontalDrift, equals(0.0));
    });

    test('should create copy with modified values', () {
      // Arrange
      const original = CoinAnimationModel(
        x: 0.5,
        size: 40.0,
        coinType: CoinType.bitcoin,
        rotationSpeed: 1.0,
        horizontalDrift: 0.1,
      );

      // Act
      final copy = original.copyWith(x: 0.8, horizontalDrift: 0.2);

      // Assert
      expect(copy.x, equals(0.8));
      expect(copy.size, equals(40.0));
      expect(copy.coinType, equals(CoinType.bitcoin));
      expect(copy.rotationSpeed, equals(1.0));
      expect(copy.horizontalDrift, equals(0.2));
    });

    test('should implement equality correctly', () {
      // Arrange
      const model1 = CoinAnimationModel(
        x: 0.5,
        size: 40.0,
        coinType: CoinType.bitcoin,
        rotationSpeed: 1.0,
      );

      const model2 = CoinAnimationModel(
        x: 0.5,
        size: 40.0,
        coinType: CoinType.bitcoin,
        rotationSpeed: 1.0,
      );

      const model3 = CoinAnimationModel(
        x: 0.5,
        size: 40.0,
        coinType: CoinType.ethereum,
        rotationSpeed: 1.0,
      );

      // Assert
      expect(model1, equals(model2));
      expect(model1, isNot(equals(model3)));
    });

    test('should implement hashCode correctly', () {
      // Arrange
      const model1 = CoinAnimationModel(
        x: 0.5,
        size: 40.0,
        coinType: CoinType.bitcoin,
        rotationSpeed: 1.0,
      );

      const model2 = CoinAnimationModel(
        x: 0.5,
        size: 40.0,
        coinType: CoinType.bitcoin,
        rotationSpeed: 1.0,
      );

      // Assert
      expect(model1.hashCode, equals(model2.hashCode));
    });

    test('should implement toString correctly', () {
      // Arrange
      const model = CoinAnimationModel(
        x: 0.5,
        size: 40.0,
        coinType: CoinType.bitcoin,
        rotationSpeed: 1.0,
        horizontalDrift: 0.1,
      );

      // Act
      final stringRepresentation = model.toString();

      // Assert
      expect(stringRepresentation, contains('CoinAnimationModel'));
      expect(stringRepresentation, contains('x: 0.5'));
      expect(stringRepresentation, contains('size: 40.0'));
      expect(stringRepresentation, contains('coinType: CoinType.bitcoin'));
    });
  });

  group('CoinType Tests', () {
    test('should have correct colors for each coin type', () {
      // Assert
      expect(CoinType.bitcoin.colors.length, equals(3));
      expect(CoinType.ethereum.colors.length, equals(3));
      expect(CoinType.tether.colors.length, equals(3));
      expect(CoinType.usd.colors.length, equals(3));
      expect(CoinType.cardano.colors.length, equals(3));
      expect(CoinType.solana.colors.length, equals(3));
      expect(CoinType.dogecoin.colors.length, equals(3));
      expect(CoinType.polygon.colors.length, equals(3));
      expect(CoinType.chainlink.colors.length, equals(3));
    });

    test('should have correct symbols for each coin type', () {
      // Assert
      expect(CoinType.bitcoin.symbol, equals('₿'));
      expect(CoinType.ethereum.symbol, equals('Ξ'));
      expect(CoinType.tether.symbol, equals('₮'));
      expect(CoinType.usd.symbol, equals('\$'));
      expect(CoinType.cardano.symbol, equals('₳'));
      expect(CoinType.solana.symbol, equals('S'));
      expect(CoinType.dogecoin.symbol, equals('Ð'));
      expect(CoinType.polygon.symbol, equals('⬟'));
      expect(CoinType.chainlink.symbol, equals('⬢'));
    });

    test('should have unique colors for each coin type', () {
      // Arrange
      final allTypes = CoinType.values;
      final colorSets = <List<Color>>[];

      // Act
      for (final type in allTypes) {
        colorSets.add(type.colors);
      }

      // Assert - Each color set should be different
      for (int i = 0; i < colorSets.length; i++) {
        for (int j = i + 1; j < colorSets.length; j++) {
          expect(
            colorSets[i].first,
            isNot(equals(colorSets[j].first)),
            reason: 'Coin types should have unique primary colors',
          );
        }
      }
    });

    test('should have valid color values', () {
      // Act & Assert
      for (final coinType in CoinType.values) {
        final colors = coinType.colors;

        for (final color in colors) {
          expect(color, isA<Color>());
          expect(color.alpha, equals(255));
        }
      }
    });

    test('should have non-empty symbols', () {
      // Act & Assert
      for (final coinType in CoinType.values) {
        expect(coinType.symbol, isNotEmpty);
        expect(coinType.symbol.length, greaterThan(0));
      }
    });

    test('should cover all enum values', () {
      // Assert
      expect(CoinType.values.length, equals(9));
      expect(CoinType.values, contains(CoinType.bitcoin));
      expect(CoinType.values, contains(CoinType.ethereum));
      expect(CoinType.values, contains(CoinType.tether));
      expect(CoinType.values, contains(CoinType.usd));
      expect(CoinType.values, contains(CoinType.cardano));
      expect(CoinType.values, contains(CoinType.solana));
      expect(CoinType.values, contains(CoinType.dogecoin));
      expect(CoinType.values, contains(CoinType.polygon));
      expect(CoinType.values, contains(CoinType.chainlink));
    });
  });
}
