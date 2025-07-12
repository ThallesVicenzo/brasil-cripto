import 'dart:async';
import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/model/repositories/home_repository.dart';
import 'package:brasil_cripto/model/service/client/errors/failure_impl.dart';
import 'package:brasil_cripto/view_model/services/favorites_service.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/secure_storage.dart';
import 'package:flutter/material.dart';

class CoinDetailsViewModel extends ChangeNotifier {
  CoinDetailsViewModel(this.coin, this.homeRepository, this.secureStorage) {
    _initializeData();
  }

  final CoinModel coin;
  final HomeRepository homeRepository;
  final SecureStorage secureStorage;
  final FavoritesService _favoritesService = sl<FavoritesService>();

  StreamSubscription<List<CoinModel>>? _favoritesSubscription;
  bool _disposed = false;

  AppLocalizations get _intl => sl<GlobalAppLocalizations>().current;

  bool isLoading = false;
  bool isFavorite = false;
  bool hasError = false;
  String errorMessage = '';

  List<double> chartData = [];
  int selectedPeriod = 1;
  List<CoinModel> favoriteCoins = [];

  final Map<String, int> periods = {
    '24h': 1,
    '7d': 7,
    '30d': 30,
    '90d': 90,
    '1y': 365,
  };

  List<String> get periodKeys => periods.keys.toList();

  String get selectedPeriodKey {
    return periods.entries
        .firstWhere((entry) => entry.value == selectedPeriod)
        .key;
  }

  void _initializeData() {
    _initializeFavorites();
    _fetchChartData();
  }

  void _initializeFavorites() async {
    await _favoritesService.loadFavorites(secureStorage);
    isFavorite = _favoritesService.isFavorite(coin.id);

    _favoritesSubscription = _favoritesService.favoritesStream.listen((
      favorites,
    ) {
      isFavorite = _favoritesService.isFavorite(coin.id);
      _safeNotifyListeners();
    });
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchChartData() async {
    isLoading = true;
    hasError = false;
    errorMessage = '';
    notifyListeners();

    final result = await homeRepository.fetchChartData(
      coinId: coin.id,
      days: selectedPeriod,
    );

    result.fold(
      (failure) {
        hasError = true;
        errorMessage = _getErrorMessage(failure);
        _generateFallbackChartData();
        isLoading = false;
        _safeNotifyListeners();
      },
      (chartModel) {
        if (chartModel.prices.isNotEmpty) {
          chartData = chartModel.prices;
        } else {
          _generateFallbackChartData();
        }
        hasError = false;
        errorMessage = '';
        isLoading = false;
        _safeNotifyListeners();
      },
    );
  }

  void _generateFallbackChartData() {
    chartData.clear();
    final basePrice = coin.currentPrice;
    final random = DateTime.now().millisecondsSinceEpoch % 1000;

    int dataPoints;
    switch (selectedPeriod) {
      case 1:
        dataPoints = 24;
        break;
      case 7:
        dataPoints = 7;
        break;
      case 30:
        dataPoints = 30;
        break;
      case 90:
        dataPoints = 90;
        break;
      case 365:
        dataPoints = 365;
        break;
      default:
        dataPoints = 24;
    }

    for (int i = 0; i < dataPoints; i++) {
      final variation = (random + i * 13) % 200 - 100;
      final price = basePrice + (basePrice * variation * 0.001);
      chartData.add(price);
    }
  }

  void changePeriod(String periodKey) {
    final newPeriod = periods[periodKey];
    if (newPeriod != null && selectedPeriod != newPeriod) {
      selectedPeriod = newPeriod;
      _fetchChartData();
    }
  }

  Future<void> toggleFavorite() async {
    await _favoritesService.toggleFavorite(coin, homeRepository);
  }

  double get priceChangeAmount {
    return coin.currentPrice * (coin.priceChangePercertage24h / 100);
  }

  bool get isPositiveChange {
    return coin.priceChangePercertage24h >= 0;
  }

  double get chartMinPrice {
    if (chartData.isEmpty) return 0.0;
    return chartData.reduce((a, b) => a < b ? a : b);
  }

  double get chartMaxPrice {
    if (chartData.isEmpty) return 0.0;
    return chartData.reduce((a, b) => a > b ? a : b);
  }

  double get chartPriceChange {
    if (chartData.length < 2) return 0.0;
    return chartData.last - chartData.first;
  }

  double get chartPriceChangePercent {
    if (chartData.length < 2 || chartData.first == 0) return 0.0;
    return ((chartData.last - chartData.first) / chartData.first) * 100;
  }

  bool get isChartPositive {
    return chartPriceChange >= 0;
  }

  Future<void> refreshData() async {
    await _fetchChartData();
  }

  Future<void> retryFetchData() async {
    await _fetchChartData();
  }

  String _getErrorMessage(dynamic failure) {
    if (failure is RateLimitFailure) {
      return _intl.rate_limit_upgrade_message;
    } else if (failure is NetworkFailure) {
      return _intl.chart_network_error;
    } else if (failure is GenericFailure) {
      return _intl.chart_server_error;
    } else {
      return _intl.chart_generic_error;
    }
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
