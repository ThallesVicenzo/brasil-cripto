import 'package:brasil_cripto/model/models/coin_chart_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoinChartModel Tests', () {
    test('should create CoinChartModel with default values', () {
      // Arrange & Act
      final model = CoinChartModel();

      // Assert
      expect(model.prices, isEmpty);
      expect(model.marketCaps, isEmpty);
      expect(model.totalVolumes, isEmpty);
    });

    test('should create CoinChartModel with provided values', () {
      // Arrange
      const prices = [100.0, 200.0, 300.0];
      const marketCaps = [1000000.0, 2000000.0, 3000000.0];
      const totalVolumes = [500000, 600000, 700000];

      // Act
      final model = CoinChartModel(
        prices: prices,
        marketCaps: marketCaps,
        totalVolumes: totalVolumes,
      );

      // Assert
      expect(model.prices, equals(prices));
      expect(model.marketCaps, equals(marketCaps));
      expect(model.totalVolumes, equals(totalVolumes));
    });

    test('should create CoinChartModel from JSON with valid data', () {
      // Arrange
      final json = {
        'prices': [
          [1640995200000, 100.5],
          [1641081600000, 200.7],
          [1641168000000, 300.9],
        ],
        'market_caps': [
          [1640995200000, 1000000.5],
          [1641081600000, 2000000.7],
          [1641168000000, 3000000.9],
        ],
        'total_volumes': [
          [1640995200000, 500000],
          [1641081600000, 600000],
          [1641168000000, 700000],
        ],
      };

      // Act
      final model = CoinChartModel.fromJson(json);

      // Assert
      expect(model.prices, equals([100.5, 200.7, 300.9]));
      expect(model.marketCaps, equals([1000000.5, 2000000.7, 3000000.9]));
      expect(model.totalVolumes, equals([500000, 600000, 700000]));
    });

    test('should create CoinChartModel from JSON with integer prices', () {
      // Arrange
      final json = {
        'prices': [
          [1640995200000, 100],
          [1641081600000, 200],
          [1641168000000, 300],
        ],
        'market_caps': [
          [1640995200000, 1000000],
          [1641081600000, 2000000],
          [1641168000000, 3000000],
        ],
        'total_volumes': [
          [1640995200000, 500000],
          [1641081600000, 600000],
          [1641168000000, 700000],
        ],
      };

      // Act
      final model = CoinChartModel.fromJson(json);

      // Assert
      expect(model.prices, equals([100.0, 200.0, 300.0]));
      expect(model.marketCaps, equals([1000000.0, 2000000.0, 3000000.0]));
      expect(model.totalVolumes, equals([500000, 600000, 700000]));
    });

    test('should create CoinChartModel from JSON with empty arrays', () {
      // Arrange
      final json = {
        'prices': <dynamic>[],
        'market_caps': <dynamic>[],
        'total_volumes': <dynamic>[],
      };

      // Act
      final model = CoinChartModel.fromJson(json);

      // Assert
      expect(model.prices, isEmpty);
      expect(model.marketCaps, isEmpty);
      expect(model.totalVolumes, isEmpty);
    });

    test('should convert CoinChartModel to JSON correctly', () {
      // Arrange
      final model = CoinChartModel(
        prices: [100.5, 200.7, 300.9],
        marketCaps: [1000000.5, 2000000.7, 3000000.9],
        totalVolumes: [500000, 600000, 700000],
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(
        json,
        equals({
          'prices': [100.5, 200.7, 300.9],
          'market_caps': [1000000.5, 2000000.7, 3000000.9],
          'total_volumes': [500000, 600000, 700000],
        }),
      );
    });

    test('should convert empty CoinChartModel to JSON correctly', () {
      // Arrange
      final model = CoinChartModel();

      // Act
      final json = model.toJson();

      // Assert
      expect(
        json,
        equals({
          'prices': <double>[],
          'market_caps': <double>[],
          'total_volumes': <int>[],
        }),
      );
    });

    test('should handle mixed number types in JSON conversion', () {
      // Arrange
      final json = {
        'prices': [
          [1640995200000, 100],
          [1641081600000, 200.5],
          [1641168000000, 300],
        ],
        'market_caps': [
          [1640995200000, 1000000],
          [1641081600000, 2000000.5],
          [1641168000000, 3000000],
        ],
        'total_volumes': [
          [1640995200000, 500000],
          [1641081600000, 600000],
          [1641168000000, 700000],
        ],
      };

      // Act
      final model = CoinChartModel.fromJson(json);
      final convertedJson = model.toJson();

      // Assert
      expect(model.prices, equals([100.0, 200.5, 300.0]));
      expect(model.marketCaps, equals([1000000.0, 2000000.5, 3000000.0]));
      expect(convertedJson['prices'], equals([100.0, 200.5, 300.0]));
      expect(
        convertedJson['market_caps'],
        equals([1000000.0, 2000000.5, 3000000.0]),
      );
    });

    test('should throw exception when JSON has invalid data types', () {
      // Arrange
      final invalidJson = {
        'prices': [
          ['invalid', 'data'],
          [1641081600000, 200.0],
        ],
        'market_caps': [
          [1640995200000, 1000000.0],
          [1641081600000, 2000000.0],
        ],
        'total_volumes': [
          [1640995200000, 500000],
          [1641081600000, 600000],
        ],
      };

      // Act & Assert
      expect(
        () => CoinChartModel.fromJson(invalidJson),
        throwsA(isA<TypeError>()),
      );
    });

    test(
      'should throw exception when total_volumes has invalid data types',
      () {
        // Arrange
        final invalidJson = {
          'prices': [
            [1640995200000, 100.0],
            [1641081600000, 200.0],
          ],
          'market_caps': [
            [1640995200000, 1000000.0],
            [1641081600000, 2000000.0],
          ],
          'total_volumes': [
            [1640995200000, 'invalid'], // string instead of number
            [1641081600000, 600000],
          ],
        };

        // Act & Assert
        expect(
          () => CoinChartModel.fromJson(invalidJson),
          throwsA(isA<TypeError>()),
        );
      },
    );
  });
}
