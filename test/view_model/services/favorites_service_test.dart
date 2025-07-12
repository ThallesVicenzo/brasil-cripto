import 'dart:convert';
import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/model/repositories/home_repository.dart';
import 'package:brasil_cripto/view_model/services/favorites_service.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/keys/secure_storage_keys.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/secure_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'favorites_service_test.mocks.dart';

@GenerateMocks([SecureStorage, HomeRepository])
void main() {
  group('FavoritesService Tests', () {
    late MockSecureStorage mockSecureStorage;
    late MockHomeRepository mockHomeRepository;

    final testCoin1 = CoinModel(
      id: 'bitcoin',
      name: 'Bitcoin',
      symbol: 'BTC',
      image: 'https://example.com/bitcoin.png',
      currentPrice: 50000.0,
      priceChangePercertage24h: 5.2,
      marketCap: 1000000000.0,
      marketCapRank: 1,
    );

    final testCoin2 = CoinModel(
      id: 'ethereum',
      name: 'Ethereum',
      symbol: 'ETH',
      image: 'https://example.com/ethereum.png',
      currentPrice: 3000.0,
      priceChangePercertage24h: -2.1,
      marketCap: 500000000.0,
      marketCapRank: 2,
    );

    setUp(() {
      mockSecureStorage = MockSecureStorage();
      mockHomeRepository = MockHomeRepository();
    });

    test('should be a singleton', () {
      // Arrange & Act
      final instance1 = FavoritesService();
      final instance2 = FavoritesService();

      // Assert
      expect(instance1, equals(instance2));
      expect(identical(instance1, instance2), true);
    });

    test('should start with empty favorites list', () {
      // Arrange & Act
      final favoritesService = FavoritesService();

      // Assert
      expect(favoritesService.favoriteCoins, isEmpty);
    });

    test('should load favorites from storage successfully', () async {
      // Arrange
      final favoritesService = FavoritesService();
      final testCoins = [testCoin1, testCoin2];
      final jsonString = JsonEncoder().convert(
        testCoins.map((coin) => coin.toJson()).toList(),
      );

      when(
        mockSecureStorage.read(key: SecureStorageKeys.getFavoriteCoins.key),
      ).thenAnswer((_) async => jsonString);

      // Act
      await favoritesService.loadFavorites(mockSecureStorage);

      // Assert
      expect(favoritesService.favoriteCoins.length, equals(2));
      expect(favoritesService.favoriteCoins[0].id, equals('bitcoin'));
      expect(favoritesService.favoriteCoins[1].id, equals('ethereum'));

      verify(
        mockSecureStorage.read(key: SecureStorageKeys.getFavoriteCoins.key),
      ).called(1);
    });

    test('should handle empty storage value', () async {
      // Arrange
      final favoritesService = FavoritesService();
      when(
        mockSecureStorage.read(key: SecureStorageKeys.getFavoriteCoins.key),
      ).thenAnswer((_) async => '');

      // Act
      await favoritesService.loadFavorites(mockSecureStorage);

      // Assert
      expect(favoritesService.favoriteCoins, isEmpty);
    });

    test('should handle null storage value', () async {
      // Arrange
      final favoritesService = FavoritesService();
      when(
        mockSecureStorage.read(key: SecureStorageKeys.getFavoriteCoins.key),
      ).thenAnswer((_) async => null);

      // Act
      await favoritesService.loadFavorites(mockSecureStorage);

      // Assert
      expect(favoritesService.favoriteCoins, isEmpty);
    });

    test('should handle storage read error gracefully', () async {
      // Arrange
      final favoritesService = FavoritesService();
      when(
        mockSecureStorage.read(key: SecureStorageKeys.getFavoriteCoins.key),
      ).thenThrow(Exception('Storage error'));

      // Act
      await favoritesService.loadFavorites(mockSecureStorage);

      // Assert
      expect(favoritesService.favoriteCoins, isEmpty);
    });

    test('should handle invalid JSON in storage gracefully', () async {
      // Arrange
      final favoritesService = FavoritesService();
      when(
        mockSecureStorage.read(key: SecureStorageKeys.getFavoriteCoins.key),
      ).thenAnswer((_) async => 'invalid json');

      // Act
      await favoritesService.loadFavorites(mockSecureStorage);

      // Assert
      expect(favoritesService.favoriteCoins, isEmpty);
    });

    test('should add coin to favorites when not already favorite', () async {
      // Arrange
      final favoritesService = FavoritesService();
      when(
        mockHomeRepository.saveFavoriteCoinsToStorage(
          favoriteCoins: anyNamed('favoriteCoins'),
        ),
      ).thenAnswer((_) async => const Right(true));

      // Act
      await favoritesService.toggleFavorite(testCoin1, mockHomeRepository);

      // Assert
      expect(favoritesService.favoriteCoins.length, equals(1));
      expect(favoritesService.favoriteCoins[0].id, equals('bitcoin'));
      expect(favoritesService.isFavorite('bitcoin'), true);

      verify(
        mockHomeRepository.saveFavoriteCoinsToStorage(
          favoriteCoins: anyNamed('favoriteCoins'),
        ),
      ).called(1);
    });

    test('should check if coin is favorite correctly', () async {
      // Arrange
      final favoritesService = FavoritesService();
      final jsonString = JsonEncoder().convert([testCoin1.toJson()]);
      when(
        mockSecureStorage.read(key: SecureStorageKeys.getFavoriteCoins.key),
      ).thenAnswer((_) async => jsonString);
      await favoritesService.loadFavorites(mockSecureStorage);

      // Act & Assert
      expect(favoritesService.isFavorite('bitcoin'), true);
      expect(favoritesService.isFavorite('ethereum'), false);
      expect(favoritesService.isFavorite('nonexistent'), false);
    });

    test('should return unmodifiable list of favorite coins', () {
      // Arrange & Act
      final favoritesService = FavoritesService();
      final favorites = favoritesService.favoriteCoins;

      // Assert
      expect(() => favorites.add(testCoin1), throwsUnsupportedError);
    });
  });
}
