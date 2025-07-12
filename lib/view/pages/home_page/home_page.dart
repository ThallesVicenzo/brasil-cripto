import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/view/pages/home_page/widgets/error_box.dart';
import 'package:brasil_cripto/view/utils/widgets/dialogs/favoritation_dialog.dart';
import 'package:brasil_cripto/view/utils/routes/app_navigator/app_navigator.dart';
import 'package:brasil_cripto/view/utils/routes/main_routes.dart';
import 'package:brasil_cripto/view/utils/widgets/buttons/coin_tile.dart';
import 'package:brasil_cripto/view/utils/widgets/colors/app_colors.dart';
import 'package:brasil_cripto/view/utils/widgets/spacing/default_padding.dart';
import 'package:brasil_cripto/view/utils/widgets/text/app_text.dart';
import 'package:brasil_cripto/view/utils/widgets/text_fields/app_text_form_field.dart';
import 'package:brasil_cripto/view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final intl = sl<GlobalAppLocalizations>().current;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(sl(), sl()),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            AppNavigator(context).pushNamed(MainRoutes.favorites.route);
          },
          backgroundColor: AppColors.primaryTransparentOrange,
          child: Icon(Icons.star, color: Colors.white),
        ),
        body: Consumer<HomeViewModel>(
          builder: (__, viewModel, _) {
            return DefaultPadding(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: AppTextFormField(
                        controller: viewModel.searchController,
                        hintText: intl.search_coins_label,
                        sufix: IconButton(
                          onPressed: () {
                            viewModel.searchController.clear();
                          },
                          icon: Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
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
                        child: ErrorBox(),
                      ),
                    )
                  else if (viewModel.showEmptyState)
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.transparentWhite,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AppText.medium(
                            intl.no_coins_found,
                            style: MyTextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (viewModel.coins.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: viewModel.coins.length,
                        itemBuilder: (context, index) {
                          final coin = viewModel.coins[index];
                          final isPositive = coin.priceChangePercertage24h >= 0;

                          return CoinTile(
                            coin: coin,
                            isPositive: isPositive,
                            isFavorite: viewModel.isFavoriteCoin(coin.id),
                            onFavoriteTap: () {
                              final isFavorite = viewModel.isFavoriteCoin(
                                coin.id,
                              );

                              showDialog(
                                context: context,
                                builder: (_) {
                                  return FavoritationDialog(
                                    isFavorite: isFavorite,
                                    viewModel: viewModel,
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
