import 'dart:async';
import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/model/repositories/home_repository.dart';
import 'package:brasil_cripto/view_model/services/favorites_service.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/secure_storage.dart';
import 'package:flutter/widgets.dart';

class FavoritesViewModel extends ChangeNotifier {
  final HomeRepository homeRepository;
  final SecureStorage secureStorage;
  final FavoritesService _favoritesService = sl<FavoritesService>();

  StreamSubscription<List<CoinModel>>? _favoritesSubscription;

  FavoritesViewModel(this.homeRepository, this.secureStorage) {
    _initializeFavorites();
  }

  bool isLoading = false;
  List<CoinModel> favoriteCoins = [];
  String? errorMessage;
  bool hasError = false;

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  void _initializeFavorites() async {
    isLoading = true;
    notifyListeners();

    await _favoritesService.loadFavorites(secureStorage);
    favoriteCoins = _favoritesService.favoriteCoins;

    _favoritesSubscription = _favoritesService.favoritesStream.listen((
      favorites,
    ) {
      favoriteCoins = favorites;
      notifyListeners();
    });

    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavoriteCoin(CoinModel coin) async {
    await _favoritesService.toggleFavorite(coin, homeRepository);
  }

  bool isFavoriteCoin(String coinId) {
    return _favoritesService.isFavorite(coinId);
  }

  Future<void> refreshFavorites() async {
    isLoading = true;
    hasError = false;
    errorMessage = null;
    notifyListeners();

    await _favoritesService.loadFavorites(secureStorage);
    favoriteCoins = _favoritesService.favoriteCoins;

    isLoading = false;
    notifyListeners();
  }

  void clearError() {
    hasError = false;
    errorMessage = null;
    notifyListeners();
  }
}
