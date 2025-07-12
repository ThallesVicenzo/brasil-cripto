import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/view/pages/home_page/widgets/error_box.dart';
import 'package:brasil_cripto/view/utils/widgets/dialogs/favoritation_dialog.dart';
import 'package:brasil_cripto/view/utils/routes/app_navigator/app_navigator.dart';
import 'package:brasil_cripto/view/utils/routes/main_routes.dart';
import 'package:brasil_cripto/view/utils/widgets/app_bar/default_app_bar.dart';
import 'package:brasil_cripto/view/utils/widgets/buttons/coin_tile.dart';
import 'package:brasil_cripto/view/utils/widgets/colors/app_colors.dart';
import 'package:brasil_cripto/view/utils/widgets/spacing/default_padding.dart';
import 'package:brasil_cripto/view/utils/widgets/text/app_text.dart';
import 'package:brasil_cripto/view_model/favorites_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final intl = sl<GlobalAppLocalizations>().current;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritesViewModel(sl(), sl()),
      child: Scaffold(
        appBar: DefaultAppBar(title: intl.favorites_title, hasLeading: true),
        body: Consumer<FavoritesViewModel>(
          builder: (__, viewModel, _) {
            return DefaultPadding.noTop(
              child: Column(
                children: [
                  if (viewModel.isLoading)
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (viewModel.hasError && viewModel.errorMessage != null)
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: ErrorBox(
                          errorMessage: viewModel.errorMessage,
                          onRetry: () {
                            viewModel.clearError();
                          },
                        ),
                      ),
                    )
                  else if (viewModel.favoriteCoins.isEmpty)
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.transparentWhite,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_border,
                                size: 64,
                                color: AppColors.disabledGray,
                              ),
                              const SizedBox(height: 16),
                              AppText.medium(
                                intl.no_favorites_found,
                                style: MyTextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AppText.small(
                                intl.add_favorites_instruction,
                                style: MyTextStyle(
                                  color: AppColors.textGray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: viewModel.refreshFavorites,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: viewModel.favoriteCoins.length,
                          itemBuilder: (context, index) {
                            final coin = viewModel.favoriteCoins[index];
                            final isPositive =
                                coin.priceChangePercertage24h >= 0;

                            return CoinTile(
                              coin: coin,
                              isPositive: isPositive,
                              isFavorite: true,
                              onFavoriteTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) {
                                    return FavoritationDialog(
                                      isFavorite: true,
                                      viewModel: null,
                                      onFavorited: () {
                                        viewModel.toggleFavoriteCoin(coin);
                                        AppNavigator(context).pop();
                                      },
                                      coin: coin,
                                    );
                                  },
                                );
                              },
                              onTap: () {
                                AppNavigator(context).pushNamed(
                                  MainRoutes.coinDetails.route,
                                  extra: coin,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
