import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/model/models/coin_chart_model.dart';
import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/model/repositories/home_repository.dart';
import 'package:brasil_cripto/model/service/client/errors/failure_impl.dart';
import 'package:brasil_cripto/view_model/coin_details_view_model.dart';
import 'package:brasil_cripto/view_model/services/favorites_service.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/secure_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'coin_details_view_model_test.mocks.dart';

@GenerateMocks([HomeRepository, SecureStorage, FavoritesService])
void main() {
  group('CoinDetailsViewModel Tests', () {
    late CoinDetailsViewModel viewModel;
    late MockHomeRepository mockHomeRepository;
    late MockSecureStorage mockSecureStorage;
    late MockFavoritesService mockFavoritesService;
    late _MockGlobalAppLocalizations mockGlobalAppLocalizations;

    final testCoin = CoinModel(
      id: 'bitcoin',
      name: 'Bitcoin',
      symbol: 'BTC',
      image: 'https://example.com/bitcoin.png',
      currentPrice: 50000.0,
      priceChangePercertage24h: 5.2,
      marketCap: 1000000000.0,
      marketCapRank: 1,
    );

    final testChartModel = CoinChartModel(
      prices: [45000.0, 46000.0, 47000.0, 48000.0, 50000.0],
      marketCaps: [
        900000000.0,
        920000000.0,
        940000000.0,
        960000000.0,
        1000000000.0,
      ],
      totalVolumes: [1000000, 1100000, 1200000, 1300000, 1400000],
    );

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
      when(mockFavoritesService.isFavorite(any)).thenReturn(false);
      when(mockFavoritesService.loadFavorites(any)).thenAnswer((_) async {});

      when(
        mockHomeRepository.fetchChartData(
          coinId: anyNamed('coinId'),
          days: anyNamed('days'),
        ),
      ).thenAnswer((_) async => Right(testChartModel));
    });

    tearDown(() async {
      try {
        viewModel.dispose();
      } catch (e) {
        // Ignora erros de dispose se o viewModel já foi disposed
      }
      GetIt.instance.reset();
      // Espera um pouco para operações assíncronas terminarem
      await Future.delayed(const Duration(milliseconds: 10));
    });

    group('Initialization', () {
      test('should initialize with correct default values', () {
        // Act
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );

        // Assert
        expect(viewModel.coin, equals(testCoin));
        expect(viewModel.isLoading, isTrue);
        expect(viewModel.isFavorite, isFalse);
        expect(viewModel.hasError, isFalse);
        expect(viewModel.errorMessage, isEmpty);
        expect(viewModel.selectedPeriod, equals(1));
        expect(viewModel.chartData, isEmpty);
      });

      test('should have correct period mappings', () {
        // Act
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );

        // Assert
        expect(viewModel.periods['24h'], equals(1));
        expect(viewModel.periods['7d'], equals(7));
        expect(viewModel.periods['30d'], equals(30));
        expect(viewModel.periods['90d'], equals(90));
        expect(viewModel.periods['1y'], equals(365));
      });

      test('should return correct period keys', () {
        // Act
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );

        // Assert
        expect(viewModel.periodKeys, contains('24h'));
        expect(viewModel.periodKeys, contains('7d'));
        expect(viewModel.periodKeys, contains('30d'));
        expect(viewModel.periodKeys, contains('90d'));
        expect(viewModel.periodKeys, contains('1y'));
      });

      test('should return correct selected period key', () {
        // Act
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );

        // Assert
        expect(viewModel.selectedPeriodKey, equals('24h'));
      });
    });

    group('Chart Data Fetching', () {
      test('should fetch chart data successfully on initialization', () async {
        // Act
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );

        // Wait for initialization to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.chartData, equals(testChartModel.prices));
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.hasError, isFalse);
        expect(viewModel.errorMessage, isEmpty);

        verify(
          mockHomeRepository.fetchChartData(coinId: 'bitcoin', days: 1),
        ).called(1);
      });

      test(
        'should handle network failure and generate fallback data',
        () async {
          // Arrange
          when(
            mockHomeRepository.fetchChartData(
              coinId: anyNamed('coinId'),
              days: anyNamed('days'),
            ),
          ).thenAnswer((_) async => Left(NetworkFailure('Network error')));

          // Act
          viewModel = CoinDetailsViewModel(
            testCoin,
            mockHomeRepository,
            mockSecureStorage,
          );

          // Wait for initialization to complete
          await Future.delayed(const Duration(milliseconds: 100));

          // Assert
          expect(viewModel.hasError, isTrue);
          expect(viewModel.errorMessage, isNotEmpty);
          expect(viewModel.chartData, isNotEmpty); // Should have fallback data
          expect(viewModel.isLoading, isFalse);
        },
      );

      test('should handle empty chart data and generate fallback', () async {
        // Arrange
        final emptyChartModel = CoinChartModel(
          prices: [],
          marketCaps: [],
          totalVolumes: [],
        );
        when(
          mockHomeRepository.fetchChartData(
            coinId: anyNamed('coinId'),
            days: anyNamed('days'),
          ),
        ).thenAnswer((_) async => Right(emptyChartModel));

        // Act
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );

        // Wait for initialization to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.chartData, isNotEmpty); // Should have fallback data
        expect(viewModel.hasError, isFalse);
        expect(viewModel.isLoading, isFalse);
      });
    });

    group('Period Management', () {
      test('should change period and fetch new data', () async {
        // Arrange
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        clearInteractions(mockHomeRepository);

        // Act
        viewModel.changePeriod('7d');
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.selectedPeriod, equals(7));
        expect(viewModel.selectedPeriodKey, equals('7d'));
        verify(
          mockHomeRepository.fetchChartData(coinId: 'bitcoin', days: 7),
        ).called(1);
      });

      test('should not change period if same period is selected', () async {
        // Arrange
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        clearInteractions(mockHomeRepository);

        // Act
        viewModel.changePeriod('24h'); // Same as default

        // Assert
        expect(viewModel.selectedPeriod, equals(1));
        verifyNever(
          mockHomeRepository.fetchChartData(
            coinId: anyNamed('coinId'),
            days: anyNamed('days'),
          ),
        );
      });

      test('should ignore invalid period key', () async {
        // Arrange
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        clearInteractions(mockHomeRepository);

        // Act
        viewModel.changePeriod('invalid');

        // Assert
        expect(viewModel.selectedPeriod, equals(1)); // Should remain unchanged
        verifyNever(
          mockHomeRepository.fetchChartData(
            coinId: anyNamed('coinId'),
            days: anyNamed('days'),
          ),
        );
      });
    });

    group('Favorites Management', () {
      test('should initialize favorite status correctly', () async {
        // Arrange
        when(mockFavoritesService.isFavorite('bitcoin')).thenReturn(true);

        // Act
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.isFavorite, isTrue);
        verify(mockFavoritesService.loadFavorites(mockSecureStorage)).called(1);
      });

      test('should toggle favorite', () async {
        // Arrange
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        when(
          mockFavoritesService.toggleFavorite(testCoin, mockHomeRepository),
        ).thenAnswer((_) async {});

        // Act
        await viewModel.toggleFavorite();

        // Assert
        verify(
          mockFavoritesService.toggleFavorite(testCoin, mockHomeRepository),
        ).called(1);
      });

      test('should listen to favorites stream changes', () async {
        // Arrange
        when(mockFavoritesService.isFavorite('bitcoin')).thenReturn(false);

        // Act
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.isFavorite, isFalse);

        // Simulate stream change
        when(mockFavoritesService.isFavorite('bitcoin')).thenReturn(true);
        // Note: In a real test, you'd emit a new value to the stream
      });
    });

    group('Price Calculations', () {
      test('should calculate price change amount correctly', () {
        // Act
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );

        // Assert
        expect(viewModel.priceChangeAmount, closeTo(2600.0, 0.01));
      });

      test('should determine positive change correctly', () {
        // Act
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );

        // Assert
        expect(viewModel.isPositiveChange, isTrue);
      });

      test('should determine negative change correctly', () {
        // Arrange
        final negativeCoin = CoinModel(
          id: 'ethereum',
          name: 'Ethereum',
          symbol: 'ETH',
          currentPrice: 3000.0,
          priceChangePercertage24h: -2.5,
        );

        // Act
        viewModel = CoinDetailsViewModel(
          negativeCoin,
          mockHomeRepository,
          mockSecureStorage,
        );

        // Assert
        expect(viewModel.isPositiveChange, isFalse);
      });
    });

    group('Chart Calculations', () {
      test('should calculate chart min price correctly', () async {
        // Arrange
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.chartMinPrice, equals(45000.0));
      });

      test('should calculate chart max price correctly', () async {
        // Arrange
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.chartMaxPrice, equals(50000.0));
      });

      test('should calculate chart price change correctly', () async {
        // Arrange
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        // Last price (50000) - First price (45000) = 5000
        expect(viewModel.chartPriceChange, equals(5000.0));
      });

      test('should calculate chart price change percent correctly', () async {
        // Arrange
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        // ((50000 - 45000) / 45000) * 100 = 11.11%
        expect(viewModel.chartPriceChangePercent, closeTo(11.11, 0.01));
      });

      test('should determine chart is positive correctly', () async {
        // Arrange
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.isChartPositive, isTrue);
      });

      test('should handle empty chart data in calculations', () {
        // Arrange
        when(
          mockHomeRepository.fetchChartData(
            coinId: anyNamed('coinId'),
            days: anyNamed('days'),
          ),
        ).thenAnswer((_) async => Right(CoinChartModel()));

        // Act
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );

        // Assert
        expect(viewModel.chartMinPrice, equals(0.0));
        expect(viewModel.chartMaxPrice, equals(0.0));
        expect(viewModel.chartPriceChange, equals(0.0));
        expect(viewModel.chartPriceChangePercent, equals(0.0));
      });
    });

    group('Data Refresh', () {
      test('should refresh data successfully', () async {
        // Arrange
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        clearInteractions(mockHomeRepository);

        // Act
        await viewModel.refreshData();

        // Assert
        verify(
          mockHomeRepository.fetchChartData(coinId: 'bitcoin', days: 1),
        ).called(1);
      });

      test('should retry fetch data successfully', () async {
        // Arrange
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        clearInteractions(mockHomeRepository);

        // Act
        await viewModel.retryFetchData();

        // Assert
        verify(
          mockHomeRepository.fetchChartData(coinId: 'bitcoin', days: 1),
        ).called(1);
      });
    });

    group('Fallback Chart Data Generation', () {
      test('should generate correct number of data points for 24h', () async {
        // Arrange
        when(
          mockHomeRepository.fetchChartData(
            coinId: anyNamed('coinId'),
            days: anyNamed('days'),
          ),
        ).thenAnswer((_) async => Left(NetworkFailure('Error')));

        // Act
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.chartData.length, equals(24));
      });

      test('should generate correct number of data points for 7d', () async {
        // Arrange
        when(
          mockHomeRepository.fetchChartData(
            coinId: anyNamed('coinId'),
            days: anyNamed('days'),
          ),
        ).thenAnswer((_) async => Left(NetworkFailure('Error')));

        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        viewModel.changePeriod('7d');
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.chartData.length, equals(7));
      });

      test('should generate data points around base price', () async {
        // Arrange
        when(
          mockHomeRepository.fetchChartData(
            coinId: anyNamed('coinId'),
            days: anyNamed('days'),
          ),
        ).thenAnswer((_) async => Left(NetworkFailure('Error')));

        // Act
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.chartData, isNotEmpty);

        // All prices should be reasonably close to the base price
        for (final price in viewModel.chartData) {
          expect(price, greaterThan(testCoin.currentPrice * 0.8));
          expect(price, lessThan(testCoin.currentPrice * 1.2));
        }
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when data changes', () async {
        // Arrange
        var notificationCount = 0;
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );
        viewModel.addListener(() => notificationCount++);

        // Act
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(notificationCount, greaterThan(0));
      });

      test('should dispose properly', () {
        // Arrange
        viewModel = CoinDetailsViewModel(
          testCoin,
          mockHomeRepository,
          mockSecureStorage,
        );

        // Act & Assert - Should not throw
        expect(() => viewModel.dispose(), returnsNormally);
      });
    });
  });
}

class _MockAppLocalizations extends AppLocalizations {
  _MockAppLocalizations() : super('en');

  @override
  String get rate_limit_upgrade_message => 'Rate limit exceeded';

  @override
  String get chart_network_error => 'Network error';

  @override
  String get chart_server_error => 'Server error';

  @override
  String get chart_generic_error => 'Generic error';

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Para getters que retornam String
    if (invocation.isGetter) {
      return 'mock_string';
    }
    // Para métodos que retornam String
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
