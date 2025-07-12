import 'dart:convert';

import 'package:brasil_cripto/model/models/coin_chart_model.dart';
import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/model/service/client/client_http.dart';
import 'package:brasil_cripto/model/service/client/client_http_exception.dart';
import 'package:brasil_cripto/model/service/client/errors/failure.dart';
import 'package:brasil_cripto/model/service/client/errors/failure_impl.dart';
import 'package:brasil_cripto/model/service/url_paths.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/keys/secure_storage_keys.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/secure_storage.dart';
import 'package:dartz/dartz.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<CoinModel>>> fetchCoins({
    required String name,
    int page,
  });

  Future<Either<Failure, CoinChartModel>> fetchChartData({
    String coinId,
    int days = 24,
  });

  Future<Either<Failure, bool>> saveFavoriteCoinsToStorage({
    required List<CoinModel> favoriteCoins,
  });
}

class HomeRepositoryImpl implements HomeRepository {
  final ClientHttp client;
  final SecureStorage secureStorage;

  HomeRepositoryImpl({required this.client, required this.secureStorage});

  @override
  Future<Either<Failure, CoinChartModel>> fetchChartData({
    String coinId = '',
    int days = 24,
  }) async {
    try {
      final response = await client.get(
        UrlPaths.chartData.buildUrl({'id': coinId}),
        queryParameters: {'days': days.toString()},
      );

      return Right(CoinChartModel.fromJson(response.data));
    } on ClientHttpException catch (e) {
      if (e.statusCode == 429) {
        bool hasUpgradeMessage = false;

        if (e.response?.data != null && e.response!.data is Map) {
          final responseData = e.response!.data as Map<String, dynamic>;
          if (responseData['status'] != null &&
              responseData['status']['error_message'] != null) {
            final apiMessage =
                responseData['status']['error_message'].toString();
            if (apiMessage.isNotEmpty) {
              hasUpgradeMessage = true;
            }
          }
        }

        return Left(RateLimitFailure(null, hasUpgradeMessage));
      } else {
        return Left(NetworkFailure(e.message));
      }
    } on NetworkFailure catch (e) {
      return Left(e);
    } on GenericFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CoinModel>>> fetchCoins({
    required String name,
    int page = 1,
  }) async {
    try {
      final response = await client.get(
        UrlPaths.search.endPoint,
        queryParameters: {'names': name, 'per_page': 10, 'page': page},
      );

      final List<CoinModel> coins =
          (response.data as List)
              .map((coin) => CoinModel.fromJson(coin))
              .toList();

      return Right(coins);
    } on ClientHttpException catch (e) {
      if (e.statusCode == 429) {
        bool hasUpgradeMessage = false;

        if (e.response?.data != null && e.response!.data is Map) {
          final responseData = e.response!.data as Map<String, dynamic>;
          if (responseData['status'] != null &&
              responseData['status']['error_message'] != null) {
            final apiMessage =
                responseData['status']['error_message'].toString();
            if (apiMessage.isNotEmpty) {
              hasUpgradeMessage = true;
            }
          }
        }

        return Left(RateLimitFailure(null, hasUpgradeMessage));
      } else {
        return Left(NetworkFailure(e.message ?? 'Erro de rede'));
      }
    } on NetworkFailure catch (e) {
      return Left(e);
    } on GenericFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> saveFavoriteCoinsToStorage({
    required List<CoinModel> favoriteCoins,
  }) async {
    try {
      final List<Map<String, dynamic>> jsonList =
          favoriteCoins.map((coin) => coin.toJson()).toList();
      final String jsonString = JsonEncoder().convert(jsonList);
      await secureStorage.write(
        key: SecureStorageKeys.getFavoriteCoins.key,
        value: jsonString,
      );
      return Right(true);
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }
}
