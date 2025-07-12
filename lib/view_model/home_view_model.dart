import 'dart:async';
import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/model/repositories/home_repository.dart';
import 'package:brasil_cripto/model/service/client/errors/failure_impl.dart';
import 'package:brasil_cripto/view_model/services/favorites_service.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/secure_storage.dart';
import 'package:flutter/widgets.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository homeRepository;
  final SecureStorage secureStorage;
  final FavoritesService _favoritesService = sl<FavoritesService>();

  StreamSubscription<List<CoinModel>>? _favoritesSubscription;

  AppLocalizations get _intl => sl<GlobalAppLocalizations>().current;

  bool _disposed = false;

  HomeViewModel(this.homeRepository, this.secureStorage) {
    _previousSearchText = searchController.text;
    searchController.addListener(onSearchChanged);
    _initializeFavorites();
  }

  final TextEditingController searchController = TextEditingController();

  bool isLoading = false;

  bool showEmptyState = false;

  List<CoinModel> coins = [];

  List<CoinModel> favoriteCoins = [];

  String? errorMessage;

  bool hasError = false;

  String _previousSearchText = '';

  Timer? _textEditing;
  final duration = const Duration(milliseconds: 900);

  @override
  void dispose() {
    _disposed = true;
    _textEditing?.cancel();
    _favoritesSubscription?.cancel();
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _initializeFavorites() async {
    await _favoritesService.loadFavorites(secureStorage);
    _favoritesSubscription = _favoritesService.favoritesStream.listen((
      favorites,
    ) {
      favoriteCoins = favorites;
      _safeNotifyListeners();
    });
  }

  Future<void> retrieveFavoriteCoins() async {
    await _favoritesService.loadFavorites(secureStorage);
    favoriteCoins = _favoritesService.favoriteCoins;
    _safeNotifyListeners();
  }

  Future<void> saveFavoriteCoin(CoinModel coin) async {
    await _favoritesService.toggleFavorite(coin, homeRepository);
  }

  Future<void> removeFavoriteCoin(String coinId) async {
    final coin = favoriteCoins.firstWhere((c) => c.id == coinId);
    await _favoritesService.toggleFavorite(coin, homeRepository);
  }

  bool isFavoriteCoin(String coinId) {
    return _favoritesService.isFavorite(coinId);
  }

  bool isCoinFromListFavorite(CoinModel coin) {
    return isFavoriteCoin(coin.id);
  }

  void updateFavoriteStatusForDisplayedCoins() {
    _safeNotifyListeners();
  }

  List<Map<String, dynamic>> get coinsWithFavoriteInfo {
    return coins
        .map((coin) => {'coin': coin, 'isFavorite': isFavoriteCoin(coin.id)})
        .toList();
  }

  Future<void> toggleFavoriteCoin(CoinModel coin) async {
    await _favoritesService.toggleFavorite(coin, homeRepository);
  }

  void clearError() {
    hasError = false;
    errorMessage = null;
    _safeNotifyListeners();
  }

  void onSearchChanged() {
    final currentText = searchController.text;

    if (currentText == _previousSearchText) {
      return;
    }

    _previousSearchText = currentText;

    if (currentText.isEmpty) {
      _textEditing?.cancel();
      coins.clear();
      showEmptyState = false;
      hasError = false;
      errorMessage = null;
      _safeNotifyListeners();
      return;
    }

    if (_textEditing != null) {
      _textEditing!.cancel();
    }

    _textEditing = Timer(duration, () => fetchData(name: currentText));
  }

  Future<void> fetchData({required String name, int page = 1}) async {
    isLoading = true;
    _safeNotifyListeners();

    final result = await homeRepository.fetchCoins(name: name, page: page);

    result.fold(
      (failure) {
        isLoading = false;
        hasError = true;

        if (failure is RateLimitFailure) {
          if (failure.hasUpgradeMessage) {
            errorMessage = _intl.rate_limit_upgrade_message;
          }
        } else if (failure is NetworkFailure) {
          errorMessage = _intl.network_error;
        } else {
          errorMessage = _intl.general_fetch_error;
        }

        _safeNotifyListeners();
      },
      (fetchedCoins) {
        coins.clear();
        coins.addAll(fetchedCoins);
        showEmptyState = fetchedCoins.isEmpty;
        isLoading = false;
        hasError = false;
        errorMessage = null;
        _safeNotifyListeners();
      },
    );
  }
}
