import 'package:brasil_cripto/model/models/coin_chart_model.dart';
import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/model/service/client/client_http.dart';
import 'package:brasil_cripto/model/service/client/errors/failure.dart';
import 'package:brasil_cripto/model/service/client/errors/failure_impl.dart';
import 'package:brasil_cripto/model/service/url_paths.dart';
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
}

class HomeRepositoryImpl implements HomeRepository {
  final ClientHttp client;

  HomeRepositoryImpl({required this.client});

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
    } on NetworkFailure catch (e) {
      return Left(e);
    } on GenericFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }
}
