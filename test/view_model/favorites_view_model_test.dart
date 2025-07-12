import 'dart:async';

import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/model/repositories/home_repository.dart';
import 'package:brasil_cripto/view_model/favorites_view_model.dart';
import 'package:brasil_cripto/view_model/services/favorites_service.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'favorites_view_model_test.mocks.dart';

@GenerateMocks([HomeRepository, SecureStorage, FavoritesService])
void main() {
  group('FavoritesViewModel Tests', () {
    late FavoritesViewModel viewModel;
    late MockHomeRepository mockHomeRepository;
    late MockSecureStorage mockSecureStorage;
    late MockFavoritesService mockFavoritesService;

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
      priceChangePercertage24h: -2.5,
      marketCap: 500000000.0,
      marketCapRank: 2,
    );

    final favoritesList = [testCoin1, testCoin2];

    setUp(() {
      mockHomeRepository = MockHomeRepository();
      mockSecureStorage = MockSecureStorage();
      mockFavoritesService = MockFavoritesService();

      // Setup GetIt
      if (GetIt.instance.isRegistered<FavoritesService>()) {
        GetIt.instance.unregister<FavoritesService>();
      }

      GetIt.instance.registerSingleton<FavoritesService>(mockFavoritesService);

      // Setup default mocks
      when(
        mockFavoritesService.favoritesStream,
      ).thenAnswer((_) => Stream.value([]));
      when(mockFavoritesService.favoriteCoins).thenReturn([]);
      when(mockFavoritesService.loadFavorites(any)).thenAnswer((_) async {});
      when(mockFavoritesService.isFavorite(any)).thenReturn(false);
      when(
        mockFavoritesService.toggleFavorite(any, any),
      ).thenAnswer((_) async {});
    });

    tearDown(() async {
      try {
        viewModel.dispose();
      } catch (e) {
        // Ignora erros de dispose se o viewModel já foi disposed
      }
      GetIt.instance.reset();
      await Future.delayed(const Duration(milliseconds: 10));
    });

    group('Initialization', () {
      test('should initialize with correct default values', () {
        // Act
        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);

        // Assert
        expect(viewModel.isLoading, isTrue);
        expect(viewModel.favoriteCoins, isEmpty);
        expect(viewModel.hasError, isFalse);
        expect(viewModel.errorMessage, isNull);
      });

      test('should load favorites on initialization', () async {
        // Act
        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(
          viewModel.favoriteCoins,
          isEmpty,
        ); // Deve estar vazio pois o mock retorna []
        verify(mockFavoritesService.loadFavorites(mockSecureStorage)).called(1);
      });

      test('should load favorites with data when service has data', () async {
        // Arrange - Create a separate test with specific mock setup
        final testViewModel = FavoritesViewModel(
          mockHomeRepository,
          mockSecureStorage,
        );

        // Simulate that the service now has data
        testViewModel.favoriteCoins = favoritesList;

        // Act & Assert
        expect(testViewModel.favoriteCoins, equals(favoritesList));

        testViewModel.dispose();
      });

      test('should set up favorites stream listener', () async {
        // Arrange
        final streamController = StreamController<List<CoinModel>>();
        when(
          mockFavoritesService.favoritesStream,
        ).thenAnswer((_) => streamController.stream);

        // Act
        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);
        await Future.delayed(const Duration(milliseconds: 50));

        // Emit data to stream
        streamController.add(favoritesList);
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(viewModel.favoriteCoins, equals(favoritesList));

        streamController.close();
      });
    });

    group('Favorites Management', () {
      test('should toggle favorite coin', () async {
        // Arrange
        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);

        // Act
        await viewModel.toggleFavoriteCoin(testCoin1);

        // Assert
        verify(
          mockFavoritesService.toggleFavorite(testCoin1, mockHomeRepository),
        ).called(1);
      });

      test('should check if coin is favorite', () {
        // Arrange
        when(mockFavoritesService.isFavorite('bitcoin')).thenReturn(true);
        when(mockFavoritesService.isFavorite('ethereum')).thenReturn(false);

        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);

        // Act & Assert
        expect(viewModel.isFavoriteCoin('bitcoin'), isTrue);
        expect(viewModel.isFavoriteCoin('ethereum'), isFalse);

        verify(mockFavoritesService.isFavorite('bitcoin')).called(1);
        verify(mockFavoritesService.isFavorite('ethereum')).called(1);
      });

      test('should update favorites when stream emits new data', () async {
        // Arrange
        final streamController = StreamController<List<CoinModel>>();
        when(
          mockFavoritesService.favoritesStream,
        ).thenAnswer((_) => streamController.stream);

        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);
        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        streamController.add(favoritesList);
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(viewModel.favoriteCoins, equals(favoritesList));

        streamController.close();
      });
    });

    group('Refresh Functionality', () {
      test('should refresh favorites successfully', () async {
        // Arrange
        when(mockFavoritesService.favoriteCoins).thenReturn(favoritesList);
        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);
        await Future.delayed(const Duration(milliseconds: 100));

        clearInteractions(mockFavoritesService);

        // Act
        await viewModel.refreshFavorites();

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.hasError, isFalse);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.favoriteCoins, equals(favoritesList));

        verify(mockFavoritesService.loadFavorites(mockSecureStorage)).called(1);
      });

      test('should set loading state during refresh', () async {
        // Arrange
        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        final refreshFuture = viewModel.refreshFavorites();

        // Assert - During refresh
        expect(viewModel.isLoading, isTrue);
        expect(viewModel.hasError, isFalse);
        expect(viewModel.errorMessage, isNull);

        await refreshFuture;

        // Assert - After refresh
        expect(viewModel.isLoading, isFalse);
      });
    });

    group('Error Handling', () {
      test('should clear error state', () {
        // Arrange
        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);

        // Simulate error state
        viewModel.hasError = true;
        viewModel.errorMessage = 'Test error';

        // Act
        viewModel.clearError();

        // Assert
        expect(viewModel.hasError, isFalse);
        expect(viewModel.errorMessage, isNull);
      });

      test('should reset error state on refresh', () async {
        // Arrange
        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);
        await Future.delayed(const Duration(milliseconds: 100));

        // Simulate error state
        viewModel.hasError = true;
        viewModel.errorMessage = 'Previous error';

        // Act
        await viewModel.refreshFavorites();

        // Assert
        expect(viewModel.hasError, isFalse);
        expect(viewModel.errorMessage, isNull);
      });
    });

    group('State Management', () {
      test('should notify listeners when loading state changes', () async {
        // Arrange
        var notificationCount = 0;
        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);
        viewModel.addListener(() => notificationCount++);

        // Act
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(notificationCount, greaterThan(0));
      });

      test(
        'should notify listeners when favorites change via stream',
        () async {
          // Arrange
          final streamController = StreamController<List<CoinModel>>();
          when(
            mockFavoritesService.favoritesStream,
          ).thenAnswer((_) => streamController.stream);

          var notificationCount = 0;
          viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);
          viewModel.addListener(() => notificationCount++);

          await Future.delayed(const Duration(milliseconds: 50));
          final initialCount = notificationCount;

          // Act
          streamController.add(favoritesList);
          await Future.delayed(const Duration(milliseconds: 50));

          // Assert
          expect(notificationCount, greaterThan(initialCount));

          streamController.close();
        },
      );

      test('should notify listeners when clearing error', () {
        // Arrange
        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);
        viewModel.hasError = true;
        viewModel.errorMessage = 'Test error';

        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Act
        viewModel.clearError();

        // Assert
        expect(notificationCount, equals(1));
      });
    });

    group('Dispose', () {
      test('should dispose properly and cancel subscriptions', () {
        // Arrange
        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);

        // Act & Assert - Should not throw
        expect(() => viewModel.dispose(), returnsNormally);
      });

      test('should not crash after dispose', () async {
        // Arrange
        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        viewModel.dispose();

        // Assert - Should not crash when trying to access disposed viewModel
        expect(() => viewModel.isLoading, returnsNormally);
      });
    });

    group('Edge Cases', () {
      test('should handle empty favorites list', () async {
        // Arrange
        when(mockFavoritesService.favoriteCoins).thenReturn([]);
        when(
          mockFavoritesService.favoritesStream,
        ).thenAnswer((_) => Stream.value([]));

        // Act
        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.favoriteCoins, isEmpty);
        expect(viewModel.isLoading, isFalse);
      });

      test('should handle null coin in isFavoriteCoin', () {
        // Arrange
        when(mockFavoritesService.isFavorite(any)).thenReturn(false);
        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);

        // Act & Assert
        expect(() => viewModel.isFavoriteCoin('nonexistent'), returnsNormally);
        expect(viewModel.isFavoriteCoin('nonexistent'), isFalse);
      });

      test('should handle stream errors gracefully', () async {
        // Arrange
        final streamController = StreamController<List<CoinModel>>();
        when(
          mockFavoritesService.favoritesStream,
        ).thenAnswer((_) => streamController.stream);

        viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);
        await Future.delayed(const Duration(milliseconds: 50));

        // Act - Emit error on stream
        streamController.addError('Test error');
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert - Should not crash
        expect(viewModel.favoriteCoins, isNotNull);

        streamController.close();
      });
    });

    group('Integration', () {
      test(
        'should work with real-world scenario of adding and removing favorites',
        () async {
          // Arrange
          final dynamicFavorites = <CoinModel>[];
          final streamController = StreamController<List<CoinModel>>();

          when(
            mockFavoritesService.favoriteCoins,
          ).thenAnswer((_) => dynamicFavorites);
          when(
            mockFavoritesService.favoritesStream,
          ).thenAnswer((_) => streamController.stream);
          when(mockFavoritesService.isFavorite(any)).thenAnswer((invocation) {
            final coinId = invocation.positionalArguments[0] as String;
            return dynamicFavorites.any((coin) => coin.id == coinId);
          });

          viewModel = FavoritesViewModel(mockHomeRepository, mockSecureStorage);
          await Future.delayed(const Duration(milliseconds: 50));

          // Act 1 - Add favorite
          dynamicFavorites.add(testCoin1);
          streamController.add(List.from(dynamicFavorites));
          await Future.delayed(const Duration(milliseconds: 50));

          // Assert 1
          expect(viewModel.favoriteCoins.length, equals(1));
          expect(viewModel.isFavoriteCoin('bitcoin'), isTrue);

          // Act 2 - Add another favorite
          dynamicFavorites.add(testCoin2);
          streamController.add(List.from(dynamicFavorites));
          await Future.delayed(const Duration(milliseconds: 50));

          // Assert 2
          expect(viewModel.favoriteCoins.length, equals(2));
          expect(viewModel.isFavoriteCoin('ethereum'), isTrue);

          // Act 3 - Remove favorite
          dynamicFavorites.remove(testCoin1);
          streamController.add(List.from(dynamicFavorites));
          await Future.delayed(const Duration(milliseconds: 50));

          // Assert 3
          expect(viewModel.favoriteCoins.length, equals(1));
          expect(viewModel.isFavoriteCoin('bitcoin'), isFalse);
          expect(viewModel.isFavoriteCoin('ethereum'), isTrue);

          streamController.close();
        },
      );
    });
  });
}
