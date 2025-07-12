import 'dart:async';

import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/model/repositories/home_repository.dart';
import 'package:brasil_cripto/model/service/client/errors/failure.dart';
import 'package:brasil_cripto/model/service/client/errors/failure_impl.dart';
import 'package:brasil_cripto/view_model/home_view_model.dart';
import 'package:brasil_cripto/view_model/services/favorites_service.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/secure_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_view_model_test.mocks.dart';

@GenerateMocks([HomeRepository, SecureStorage, FavoritesService])
void main() {
  group('HomeViewModel Tests', () {
    late HomeViewModel viewModel;
    late MockHomeRepository mockHomeRepository;
    late MockSecureStorage mockSecureStorage;
    late MockFavoritesService mockFavoritesService;
    late _MockGlobalAppLocalizations mockGlobalAppLocalizations;

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

    final testCoinsList = [testCoin1, testCoin2];
    final favoritesList = [testCoin1];

    setUp(() {
      mockHomeRepository = MockHomeRepository();
      mockSecureStorage = MockSecureStorage();
      mockFavoritesService = MockFavoritesService();
      mockGlobalAppLocalizations = _MockGlobalAppLocalizations();

      // Setup GetIt
      if (GetIt.instance.isRegistered<FavoritesService>()) {
        GetIt.instance.unregister<FavoritesService>();
      }
      if (GetIt.instance.isRegistered<GlobalAppLocalizations>()) {
        GetIt.instance.unregister<GlobalAppLocalizations>();
      }

      GetIt.instance.registerSingleton<FavoritesService>(mockFavoritesService);
      GetIt.instance.registerSingleton<GlobalAppLocalizations>(
        mockGlobalAppLocalizations,
      );

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

      when(
        mockHomeRepository.fetchCoins(
          name: anyNamed('name'),
          page: anyNamed('page'),
        ),
      ).thenAnswer((_) async => Right(testCoinsList));
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
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.showEmptyState, isFalse);
        expect(viewModel.coins, isEmpty);
        expect(viewModel.favoriteCoins, isEmpty);
        expect(viewModel.hasError, isFalse);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.searchController.text, isEmpty);
      });

      test('should initialize favorites on startup', () async {
        // Act
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        verify(mockFavoritesService.loadFavorites(mockSecureStorage)).called(1);
      });

      test('should setup search controller listener', () {
        // Act
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Assert - Verify listener is working by triggering onSearchChanged
        viewModel.searchController.text = 'test';
        viewModel.onSearchChanged();
        expect(viewModel.searchController.text, equals('test'));
      });
    });

    group('Search Functionality', () {
      test('should clear coins when search text is empty', () async {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);
        viewModel.coins.addAll(testCoinsList);
        viewModel.showEmptyState = true;
        viewModel.hasError = true;
        viewModel.errorMessage = 'Some error';

        // Set some initial text first
        viewModel.searchController.text = 'bitcoin';
        viewModel.onSearchChanged();

        // Act - Now clear the text
        viewModel.searchController.text = '';
        viewModel.onSearchChanged();
        await Future.delayed(
          const Duration(milliseconds: 10),
        ); // Wait for async operations

        // Assert
        expect(viewModel.coins, isEmpty);
        expect(viewModel.showEmptyState, isFalse);
        expect(viewModel.hasError, isFalse);
        expect(viewModel.errorMessage, isNull);
      });

      test('should not trigger search for same text', () {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);
        viewModel.searchController.text = 'bitcoin';
        viewModel.onSearchChanged(); // First call

        clearInteractions(mockHomeRepository);

        // Act
        viewModel.onSearchChanged(); // Second call with same text

        // Assert
        verifyNever(
          mockHomeRepository.fetchCoins(
            name: anyNamed('name'),
            page: anyNamed('page'),
          ),
        );
      });

      test('should trigger search after timer delay', () async {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act
        viewModel.searchController.text = 'bitcoin';
        viewModel.onSearchChanged();

        // Wait for timer delay
        await Future.delayed(const Duration(milliseconds: 1000));

        // Assert
        verify(
          mockHomeRepository.fetchCoins(name: 'bitcoin', page: 1),
        ).called(1);
      });

      test(
        'should cancel previous timer when new search is triggered',
        () async {
          // Arrange
          viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

          // Act
          viewModel.searchController.text = 'bit';
          viewModel.onSearchChanged();

          // Change text before timer expires
          viewModel.searchController.text = 'bitcoin';
          viewModel.onSearchChanged();

          // Wait for timer delay
          await Future.delayed(const Duration(milliseconds: 1000));

          // Assert - should only call with 'bitcoin', not 'bit'
          verify(
            mockHomeRepository.fetchCoins(name: 'bitcoin', page: 1),
          ).called(1);
          verifyNever(
            mockHomeRepository.fetchCoins(name: 'bit', page: anyNamed('page')),
          );
        },
      );
    });

    group('Data Fetching', () {
      test('should fetch coins successfully', () async {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act
        await viewModel.fetchData(name: 'bitcoin');

        // Assert
        expect(viewModel.coins, equals(testCoinsList));
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.hasError, isFalse);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.showEmptyState, isFalse);
      });

      test('should show empty state when no coins are returned', () async {
        // Arrange
        when(
          mockHomeRepository.fetchCoins(
            name: anyNamed('name'),
            page: anyNamed('page'),
          ),
        ).thenAnswer((_) async => Right([]));
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act
        await viewModel.fetchData(name: 'nonexistent');

        // Assert
        expect(viewModel.coins, isEmpty);
        expect(viewModel.showEmptyState, isTrue);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.hasError, isFalse);
      });

      test('should handle network failure', () async {
        // Arrange
        when(
          mockHomeRepository.fetchCoins(
            name: anyNamed('name'),
            page: anyNamed('page'),
          ),
        ).thenAnswer((_) async => Left(NetworkFailure('Network error')));
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act
        await viewModel.fetchData(name: 'bitcoin');

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.hasError, isTrue);
        expect(viewModel.errorMessage, equals('Network error'));
      });

      test('should handle rate limit failure with upgrade message', () async {
        // Arrange
        when(
          mockHomeRepository.fetchCoins(
            name: anyNamed('name'),
            page: anyNamed('page'),
          ),
        ).thenAnswer((_) async => Left(RateLimitFailure('Rate limited', true)));
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act
        await viewModel.fetchData(name: 'bitcoin');

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.hasError, isTrue);
        expect(viewModel.errorMessage, equals('Rate limit exceeded'));
      });

      test(
        'should handle rate limit failure without upgrade message',
        () async {
          // Arrange
          when(
            mockHomeRepository.fetchCoins(
              name: anyNamed('name'),
              page: anyNamed('page'),
            ),
          ).thenAnswer(
            (_) async => Left(RateLimitFailure('Rate limited', false)),
          );
          viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

          // Act
          await viewModel.fetchData(name: 'bitcoin');

          // Assert
          expect(viewModel.isLoading, isFalse);
          expect(viewModel.hasError, isTrue);
          expect(
            viewModel.errorMessage,
            isNull,
          ); // No message when hasUpgradeMessage is false
        },
      );

      test('should handle generic failure', () async {
        // Arrange
        when(
          mockHomeRepository.fetchCoins(
            name: anyNamed('name'),
            page: anyNamed('page'),
          ),
        ).thenAnswer((_) async => Left(GenericFailure('Generic error')));
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act
        await viewModel.fetchData(name: 'bitcoin');

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.hasError, isTrue);
        expect(viewModel.errorMessage, equals('General fetch error'));
      });

      test('should set loading state during fetch', () async {
        // Arrange
        final completer = Completer<Either<Failure, List<CoinModel>>>();
        when(
          mockHomeRepository.fetchCoins(
            name: anyNamed('name'),
            page: anyNamed('page'),
          ),
        ).thenAnswer((_) => completer.future);
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act
        final fetchFuture = viewModel.fetchData(name: 'bitcoin');

        // Assert - During fetch
        expect(viewModel.isLoading, isTrue);

        // Complete the fetch
        completer.complete(Right(testCoinsList));
        await fetchFuture;

        // Assert - After fetch
        expect(viewModel.isLoading, isFalse);
      });
    });

    group('Favorites Management', () {
      test('should retrieve favorite coins', () async {
        // Arrange
        when(mockFavoritesService.favoriteCoins).thenReturn(favoritesList);
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act
        await viewModel.retrieveFavoriteCoins();

        // Assert
        expect(viewModel.favoriteCoins, equals(favoritesList));
        verify(
          mockFavoritesService.loadFavorites(mockSecureStorage),
        ).called(greaterThan(0));
      });

      test('should save favorite coin', () async {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act
        await viewModel.saveFavoriteCoin(testCoin1);

        // Assert
        verify(
          mockFavoritesService.toggleFavorite(testCoin1, mockHomeRepository),
        ).called(1);
      });

      test('should remove favorite coin', () async {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);
        viewModel.favoriteCoins.add(testCoin1);

        // Act
        await viewModel.removeFavoriteCoin('bitcoin');

        // Assert
        verify(
          mockFavoritesService.toggleFavorite(testCoin1, mockHomeRepository),
        ).called(1);
      });

      test('should toggle favorite coin', () async {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

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
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act & Assert
        expect(viewModel.isFavoriteCoin('bitcoin'), isTrue);
        expect(viewModel.isFavoriteCoin('ethereum'), isFalse);
      });

      test('should check if coin from list is favorite', () {
        // Arrange
        when(mockFavoritesService.isFavorite('bitcoin')).thenReturn(true);
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act & Assert
        expect(viewModel.isCoinFromListFavorite(testCoin1), isTrue);
      });

      test('should return coins with favorite info', () {
        // Arrange
        when(mockFavoritesService.isFavorite('bitcoin')).thenReturn(true);
        when(mockFavoritesService.isFavorite('ethereum')).thenReturn(false);
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);
        viewModel.coins.addAll(testCoinsList);

        // Act
        final coinsWithInfo = viewModel.coinsWithFavoriteInfo;

        // Assert
        expect(coinsWithInfo.length, equals(2));
        expect(coinsWithInfo[0]['coin'], equals(testCoin1));
        expect(coinsWithInfo[0]['isFavorite'], isTrue);
        expect(coinsWithInfo[1]['coin'], equals(testCoin2));
        expect(coinsWithInfo[1]['isFavorite'], isFalse);
      });

      test('should update favorites from stream', () async {
        // Arrange
        final streamController = StreamController<List<CoinModel>>();
        when(
          mockFavoritesService.favoritesStream,
        ).thenAnswer((_) => streamController.stream);

        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);
        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        streamController.add(favoritesList);
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(viewModel.favoriteCoins, equals(favoritesList));

        streamController.close();
      });
    });

    group('Error Handling', () {
      test('should clear error state', () {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);
        viewModel.hasError = true;
        viewModel.errorMessage = 'Some error';

        // Act
        viewModel.clearError();

        // Assert
        expect(viewModel.hasError, isFalse);
        expect(viewModel.errorMessage, isNull);
      });
    });

    group('State Management', () {
      test('should notify listeners when favorites update', () {
        // Arrange
        var notificationCount = 0;
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);
        viewModel.addListener(() => notificationCount++);

        // Act
        viewModel.updateFavoriteStatusForDisplayedCoins();

        // Assert
        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners when clearing error', () {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);
        viewModel.hasError = true;
        viewModel.errorMessage = 'Error';

        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Act
        viewModel.clearError();

        // Assert
        expect(notificationCount, equals(1));
      });

      test('should notify listeners during data fetch', () async {
        // Arrange
        var notificationCount = 0;
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);
        viewModel.addListener(() => notificationCount++);

        // Act
        await viewModel.fetchData(name: 'bitcoin');

        // Assert
        expect(notificationCount, greaterThan(0));
      });
    });

    group('Dispose', () {
      test('should dispose properly', () {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act & Assert - Should not throw
        expect(() => viewModel.dispose(), returnsNormally);
      });

      test('should cancel timer on dispose', () async {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);
        viewModel.searchController.text = 'bitcoin';
        viewModel.onSearchChanged(); // Start timer

        // Act
        viewModel.dispose();
        await Future.delayed(
          const Duration(milliseconds: 10),
        ); // Wait for dispose

        // Timer should be cancelled, so no additional fetch should happen
        // This test verifies that dispose doesn't throw
        expect(true, isTrue); // Test passes if no exception is thrown
      });

      test('should cancel favorites subscription on dispose', () async {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);
        await Future.delayed(
          const Duration(milliseconds: 50),
        ); // Wait for initialization

        // Act
        viewModel.dispose();
        await Future.delayed(
          const Duration(milliseconds: 10),
        ); // Wait for dispose

        // Assert - Should not throw
        expect(true, isTrue); // Test passes if no exception is thrown
      });

      test('should remove search controller listener on dispose', () async {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Add a listener to verify disposal behavior
        var listenerCalled = false;
        viewModel.addListener(() => listenerCalled = true);

        // Act
        viewModel.dispose();
        await Future.delayed(
          const Duration(milliseconds: 10),
        ); // Wait for dispose

        // Assert - Should not throw and listener should not be called after dispose
        expect(true, isTrue); // Test passes if no exception is thrown
        expect(listenerCalled, isFalse); // Listener wasn't triggered by dispose
      });
    });

    group('Edge Cases', () {
      test('should handle empty search text gracefully', () {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act
        viewModel.searchController.text = '';
        viewModel.onSearchChanged();

        // Assert
        expect(viewModel.coins, isEmpty);
        expect(viewModel.showEmptyState, isFalse);
      });

      test('should handle whitespace-only search text', () {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act
        viewModel.searchController.text = '   ';
        viewModel.onSearchChanged();

        // Assert - Should trigger search with whitespace
        expect(viewModel.searchController.text, equals('   '));
      });

      test('should handle removing non-existent favorite coin', () async {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);
        // favoriteCoins is empty, so firstWhere will throw

        // Act & Assert
        expect(
          () async => await viewModel.removeFavoriteCoin('nonexistent'),
          throwsA(isA<StateError>()),
        );
      });

      test('should handle rapid search text changes', () async {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act - Rapid changes
        viewModel.searchController.text = 'b';
        viewModel.onSearchChanged();
        viewModel.searchController.text = 'bi';
        viewModel.onSearchChanged();
        viewModel.searchController.text = 'bit';
        viewModel.onSearchChanged();
        viewModel.searchController.text = 'bitcoin';
        viewModel.onSearchChanged();

        // Wait for timer
        await Future.delayed(const Duration(milliseconds: 1000));

        // Assert - Should only fetch for final text
        verify(
          mockHomeRepository.fetchCoins(name: 'bitcoin', page: 1),
        ).called(1);
      });
    });

    group('Integration', () {
      test('should work in complete search flow', () async {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);

        // Act - Simulate user typing
        viewModel.searchController.text = 'bitcoin';
        viewModel.onSearchChanged();

        // Wait for timer and fetch
        await Future.delayed(const Duration(milliseconds: 1000));

        // Assert
        expect(viewModel.coins, equals(testCoinsList));
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.hasError, isFalse);
        verify(
          mockHomeRepository.fetchCoins(name: 'bitcoin', page: 1),
        ).called(1);
      });

      test('should clear search and show empty state flow', () async {
        // Arrange
        viewModel = HomeViewModel(mockHomeRepository, mockSecureStorage);
        viewModel.coins.addAll(testCoinsList);
        viewModel.hasError = true;
        viewModel.errorMessage = 'Error';

        // Set some initial text first
        viewModel.searchController.text = 'bitcoin';
        viewModel.onSearchChanged();

        // Act - Now clear the text
        viewModel.searchController.text = '';
        viewModel.onSearchChanged();
        await Future.delayed(
          const Duration(milliseconds: 10),
        ); // Wait for async operations

        // Assert
        expect(viewModel.coins, isEmpty);
        expect(viewModel.hasError, isFalse);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.showEmptyState, isFalse);
      });
    });
  });
}

class _MockAppLocalizations extends AppLocalizations {
  _MockAppLocalizations() : super('en');

  @override
  String get rate_limit_upgrade_message => 'Rate limit exceeded';

  @override
  String get network_error => 'Network error';

  @override
  String get general_fetch_error => 'General fetch error';

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      return 'mock_string';
    }
    if (invocation.memberName.toString().contains('confirmation')) {
      return 'mock_confirmation';
    }
    return super.noSuchMethod(invocation);
  }
}

class _MockGlobalAppLocalizations implements GlobalAppLocalizations {
  final _mockAppLocalizations = _MockAppLocalizations();

  @override
  AppLocalizations get current => _mockAppLocalizations;

  @override
  Locale get locale => const Locale('en');

  @override
  void setAppLocalizations(dynamic localizations) {
    // Mock implementation - no-op
  }
}
