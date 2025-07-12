import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/model/repositories/home_repository.dart';
import 'package:brasil_cripto/model/service/client/client_http_request.dart';
import 'package:brasil_cripto/model/service/client/dio/dio_client.dart';
import 'package:brasil_cripto/model/service/client/errors/failure_impl.dart';
import 'package:brasil_cripto/model/service/url_paths.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_repository_test.mocks.dart';

@GenerateMocks([DioClient, SecureStorage])
void main() {
  late HomeRepositoryImpl repository;
  late MockDioClient mockClient;
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockClient = MockDioClient();
    mockSecureStorage = MockSecureStorage();
    repository = HomeRepositoryImpl(
      client: mockClient,
      secureStorage: mockSecureStorage,
    );
  });

  group('HomeRepository Tests', () {
    const testCoinName = 'bitcoin';

    final mockCoinData = [
      {
        'id': 'bitcoin',
        'name': 'Bitcoin',
        'symbol': 'btc',
        'image': 'https://example.com/bitcoin.png',
        'market_cap_rank': 1,
        'current_price': 50000.0,
        'price_change_percentage_24h': 5.2,
        'market_cap': 1000000000.0,
      },
      {
        'id': 'ethereum',
        'name': 'Ethereum',
        'symbol': 'eth',
        'image': 'https://example.com/ethereum.png',
        'market_cap_rank': 2,
        'current_price': 3000.0,
        'price_change_percentage_24h': -2.1,
        'market_cap': 500000000.0,
      },
    ];

    final mockChartData = {
      'prices': [
        [1640995200000, 45000.0],
        [1641081600000, 46000.0],
        [1641168000000, 47000.0],
        [1641254400000, 50000.0],
      ],
      'market_caps': [
        [1640995200000, 900000000.0],
        [1641081600000, 920000000.0],
        [1641168000000, 940000000.0],
        [1641254400000, 1000000000.0],
      ],
      'total_volumes': [
        [1640995200000, 1000000],
        [1641081600000, 1100000],
        [1641168000000, 1200000],
        [1641254400000, 1300000],
      ],
    };

    test('should return list of coins when fetchData is successful', () async {
      // Arrange
      when(
        mockClient.get(
          UrlPaths.search.endPoint,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => ClientHttpRequest<dynamic>(
          data: mockCoinData,
          statusCode: 200,
          statusMessage: 'OK',
        ),
      );

      // Act
      final result = await repository.fetchCoins(name: testCoinName);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (coins) {
          expect(coins, isA<List<CoinModel>>());
          expect(coins.length, 2);
          expect(coins[0].id, 'bitcoin');
          expect(coins[0].name, 'Bitcoin');
          expect(coins[1].id, 'ethereum');
          expect(coins[1].name, 'Ethereum');
        },
      );

      verify(
        mockClient.get(
          UrlPaths.search.endPoint,
          queryParameters: {'names': testCoinName, 'per_page': 10, 'page': 1},
        ),
      ).called(1);
    });

    test('should return empty list when API returns empty data', () async {
      // Arrange
      when(
        mockClient.get(
          UrlPaths.search.endPoint,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => ClientHttpRequest<dynamic>(
          data: [],
          statusCode: 200,
          statusMessage: 'OK',
        ),
      );

      // Act
      final result = await repository.fetchCoins(name: testCoinName);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (coins) {
          expect(coins, isA<List<CoinModel>>());
          expect(coins.isEmpty, true);
        },
      );
    });

    test('should return empty list when API returns null data', () async {
      // Arrange
      when(
        mockClient.get(
          UrlPaths.search.endPoint,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => ClientHttpRequest<dynamic>(
          data: null,
          statusCode: 200,
          statusMessage: 'OK',
        ),
      );

      // Act
      final result = await repository.fetchCoins(name: testCoinName);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<GenericFailure>());
      }, (coins) => fail('Expected failure but got success: $coins'));
    });

    test('should return NetworkFailure when network error occurs', () async {
      // Arrange
      when(
        mockClient.get(
          UrlPaths.search.endPoint,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenThrow(const NetworkFailure('Network connection failed'));

      // Act
      final result = await repository.fetchCoins(name: testCoinName);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, 'Network connection failed');
      }, (coins) => fail('Expected failure but got success: $coins'));
    });

    test('should return GenericFailure when generic error occurs', () async {
      // Arrange
      when(
        mockClient.get(
          UrlPaths.search.endPoint,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenThrow(const GenericFailure('Generic error occurred'));

      // Act
      final result = await repository.fetchCoins(name: testCoinName);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<GenericFailure>());
        expect(failure.message, 'Generic error occurred');
      }, (coins) => fail('Expected failure but got success: $coins'));
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(
        mockClient.get(
          UrlPaths.search.endPoint,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.fetchCoins(name: testCoinName);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<GenericFailure>());
        expect(failure.message, 'Exception: Unexpected error');
      }, (coins) => fail('Expected failure but got success: $coins'));
    });

    test('should use correct page parameter when provided', () async {
      // Arrange
      const customPage = 2;
      when(
        mockClient.get(
          UrlPaths.search.endPoint,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => ClientHttpRequest<dynamic>(
          data: [],
          statusCode: 200,
          statusMessage: 'OK',
        ),
      );

      // Act
      await repository.fetchCoins(name: testCoinName, page: customPage);

      // Assert
      verify(
        mockClient.get(
          UrlPaths.search.endPoint,
          queryParameters: {
            'names': testCoinName,
            'per_page': 10,
            'page': customPage,
          },
        ),
      ).called(1);
    });

    test('should fetch chart data successfully', () async {
      // Arrange
      const coinId = 'bitcoin';
      const days = 7;

      when(
        mockClient.get(
          UrlPaths.chartData.buildUrl({'id': coinId}),
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => ClientHttpRequest<dynamic>(
          data: mockChartData,
          statusCode: 200,
          statusMessage: 'OK',
        ),
      );

      // Act
      final result = await repository.fetchChartData(
        coinId: coinId,
        days: days,
      );

      // Assert
      expect(result.isRight(), true);
      verify(
        mockClient.get(
          UrlPaths.chartData.buildUrl({'id': coinId}),
          queryParameters: {'days': days.toString()},
        ),
      ).called(1);
    });

    test('should save favorite coins to storage successfully', () async {
      // Arrange
      final favoriteCoins = [
        CoinModel.fromJson(mockCoinData[0]),
        CoinModel.fromJson(mockCoinData[1]),
      ];

      when(
        mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')),
      ).thenAnswer((_) async {});

      // Act
      final result = await repository.saveFavoriteCoinsToStorage(
        favoriteCoins: favoriteCoins,
      );

      // Assert
      expect(result.isRight(), true);
      verify(
        mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')),
      ).called(1);
    });
  });
}
