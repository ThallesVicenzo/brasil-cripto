import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoinModel Tests', () {
    test('should create CoinModel with required id only', () {
      // Arrange & Act
      final model = CoinModel(id: 'bitcoin');

      // Assert
      expect(model.id, equals('bitcoin'));
      expect(model.name, equals(''));
      expect(model.symbol, equals(''));
      expect(model.image, equals(''));
      expect(model.marketCapRank, equals(0));
      expect(model.currentPrice, equals(0.0));
      expect(model.priceChangePercertage24h, equals(0.0));
      expect(model.marketCap, equals(0.0));
    });

    test('should create CoinModel with all provided values', () {
      // Act
      final model = CoinModel(
        id: 'bitcoin',
        name: 'Bitcoin',
        symbol: 'BTC',
        image: 'https://example.com/bitcoin.png',
        marketCapRank: 1,
        currentPrice: 50000.0,
        priceChangePercertage24h: 5.2,
        marketCap: 1000000000.0,
      );

      // Assert
      expect(model.id, equals('bitcoin'));
      expect(model.name, equals('Bitcoin'));
      expect(model.symbol, equals('BTC'));
      expect(model.image, equals('https://example.com/bitcoin.png'));
      expect(model.marketCapRank, equals(1));
      expect(model.currentPrice, equals(50000.0));
      expect(model.priceChangePercertage24h, equals(5.2));
      expect(model.marketCap, equals(1000000000.0));
    });

    test('should create CoinModel from JSON with valid data', () {
      // Arrange
      final json = {
        'id': 'bitcoin',
        'name': 'Bitcoin',
        'symbol': 'BTC',
        'image': 'https://example.com/bitcoin.png',
        'market_cap_rank': 1,
        'current_price': 50000.0,
        'price_change_percentage_24h': 5.2,
        'market_cap': 1000000000.0,
      };

      // Act
      final model = CoinModel.fromJson(json);

      // Assert
      expect(model.id, equals('bitcoin'));
      expect(model.name, equals('Bitcoin'));
      expect(model.symbol, equals('BTC'));
      expect(model.image, equals('https://example.com/bitcoin.png'));
      expect(model.marketCapRank, equals(1));
      expect(model.currentPrice, equals(50000.0));
      expect(model.priceChangePercertage24h, equals(5.2));
      expect(model.marketCap, equals(1000000000.0));
    });

    test('should create CoinModel from JSON with integer values', () {
      // Arrange
      final json = {
        'id': 'ethereum',
        'name': 'Ethereum',
        'symbol': 'ETH',
        'image': 'https://example.com/ethereum.png',
        'market_cap_rank': 2,
        'current_price': 3000,
        'price_change_percentage_24h': -2,
        'market_cap': 500000000,
      };

      // Act
      final model = CoinModel.fromJson(json);

      // Assert
      expect(model.id, equals('ethereum'));
      expect(model.name, equals('Ethereum'));
      expect(model.symbol, equals('ETH'));
      expect(model.currentPrice, equals(3000.0));
      expect(model.priceChangePercertage24h, equals(-2.0));
      expect(model.marketCap, equals(500000000.0));
    });

    test('should convert CoinModel to JSON correctly', () {
      // Arrange
      final model = CoinModel(
        id: 'bitcoin',
        name: 'Bitcoin',
        symbol: 'BTC',
        image: 'https://example.com/bitcoin.png',
        marketCapRank: 1,
        currentPrice: 50000.0,
        priceChangePercertage24h: 5.2,
        marketCap: 1000000000.0,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(
        json,
        equals({
          'id': 'bitcoin',
          'name': 'Bitcoin',
          'image': 'https://example.com/bitcoin.png',
          'symbol': 'BTC',
          'market_cap_rank': 1,
          'current_price': 50000.0,
          'price_change_percentage_24h': 5.2,
          'market_cap': 1000000000.0,
        }),
      );
    });

    test('should handle negative values correctly', () {
      // Arrange
      final json = {
        'id': 'test-coin',
        'name': 'Test Coin',
        'symbol': 'TEST',
        'image': 'https://example.com/test.png',
        'market_cap_rank': 100,
        'current_price': 0.001,
        'price_change_percentage_24h': -15.75,
        'market_cap': 50000.0,
      };

      // Act
      final model = CoinModel.fromJson(json);

      // Assert
      expect(model.currentPrice, equals(0.001));
      expect(model.priceChangePercertage24h, equals(-15.75));
      expect(model.marketCap, equals(50000.0));
    });

    test('should handle zero values correctly', () {
      // Arrange
      final json = {
        'id': 'zero-coin',
        'name': 'Zero Coin',
        'symbol': 'ZERO',
        'image': 'https://example.com/zero.png',
        'market_cap_rank': 0,
        'current_price': 0.0,
        'price_change_percentage_24h': 0.0,
        'market_cap': 0.0,
      };

      // Act
      final model = CoinModel.fromJson(json);

      // Assert
      expect(model.marketCapRank, equals(0));
      expect(model.currentPrice, equals(0.0));
      expect(model.priceChangePercertage24h, equals(0.0));
      expect(model.marketCap, equals(0.0));
    });

    test('should throw exception when JSON is missing required id field', () {
      // Arrange
      final invalidJson = {
        'name': 'Bitcoin',
        'symbol': 'BTC',
        'image': 'https://example.com/bitcoin.png',
        'market_cap_rank': 1,
        'current_price': 50000.0,
        'price_change_percentage_24h': 5.2,
        'market_cap': 1000000000.0,
      };

      // Act & Assert
      expect(() => CoinModel.fromJson(invalidJson), throwsA(isA<TypeError>()));
    });
  });
}
