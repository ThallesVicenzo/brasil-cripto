import 'dart:async';
import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/model/repositories/home_repository.dart';
import 'package:flutter/widgets.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository homeRepository;

  HomeViewModel(this.homeRepository) {
    _previousSearchText = searchController.text;
    searchController.addListener(onSearchChanged);
  }

  final TextEditingController searchController = TextEditingController();

  bool isLoading = false;

  bool showEmptyState = false;

  List<CoinModel> coins = [];

  String _previousSearchText = '';

  Timer? _textEditing;
  final duration = const Duration(milliseconds: 900);

  @override
  void dispose() {
    _textEditing?.cancel();
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    super.dispose();
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
      notifyListeners();
      return;
    }

    if (_textEditing != null) {
      _textEditing!.cancel();
    }

    _textEditing = Timer(duration, () => fetchData(name: currentText));
  }

  Future<void> fetchData({required String name, int page = 1}) async {
    isLoading = true;
    notifyListeners();

    final result = await homeRepository.fetchCoins(name: name, page: page);

    result.fold(
      (failure) {
        isLoading = false;
        notifyListeners();
      },
      (fetchedCoins) {
        coins.clear();
        coins.addAll(fetchedCoins);
        showEmptyState = fetchedCoins.isEmpty;
        isLoading = false;
        notifyListeners();
      },
    );
  }
}
