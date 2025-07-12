import 'dart:async';
import 'dart:convert';
import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/model/repositories/home_repository.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/keys/secure_storage_keys.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/secure_storage.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final StreamController<List<CoinModel>> _favoritesController =
      StreamController<List<CoinModel>>.broadcast();

  Stream<List<CoinModel>> get favoritesStream => _favoritesController.stream;

  List<CoinModel> _favoriteCoins = [];
  List<CoinModel> get favoriteCoins => List.unmodifiable(_favoriteCoins);

  Future<void> loadFavorites(SecureStorage secureStorage) async {
    try {
      final value = await secureStorage.read(
        key: SecureStorageKeys.getFavoriteCoins.key,
      );
      if (value != null && value.isNotEmpty) {
        final List<dynamic> jsonList = JsonDecoder().convert(value);
        _favoriteCoins =
            jsonList
                .map((json) => CoinModel.fromJson(json as Map<String, dynamic>))
                .toList();
      } else {
        _favoriteCoins = [];
      }
      _favoritesController.add(_favoriteCoins);
    } catch (e) {
      _favoriteCoins = [];
      _favoritesController.add(_favoriteCoins);
    }
  }

  Future<void> toggleFavorite(
    CoinModel coin,
    HomeRepository homeRepository,
  ) async {
    final existingIndex = _favoriteCoins.indexWhere((c) => c.id == coin.id);

    if (existingIndex != -1) {
      _favoriteCoins.removeAt(existingIndex);
    } else {
      _favoriteCoins.add(coin);
    }

    final result = await homeRepository.saveFavoriteCoinsToStorage(
      favoriteCoins: _favoriteCoins,
    );

    result.fold(
      (failure) {
        // Reverte a mudança em caso de erro
        if (existingIndex != -1) {
          _favoriteCoins.insert(existingIndex, coin);
        } else {
          _favoriteCoins.removeWhere((c) => c.id == coin.id);
        }
      },
      (success) {
        // Mudança foi salva com sucesso
      },
    );

    _favoritesController.add(_favoriteCoins);
  }

  bool isFavorite(String coinId) {
    return _favoriteCoins.any((coin) => coin.id == coinId);
  }

  void dispose() {
    _favoritesController.close();
  }
}
