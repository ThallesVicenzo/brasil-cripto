import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/view/utils/widgets/colors/app_colors.dart';
import 'package:brasil_cripto/view/utils/widgets/images/network_image_widget.dart';
import 'package:brasil_cripto/view/utils/widgets/text/app_text.dart';
import 'package:brasil_cripto/view_model/coin_details_view_model.dart';
import 'package:brasil_cripto/view_model/utils/formatters/currency_formatter.dart';
import 'package:flutter/material.dart';

class CoinHeader extends StatelessWidget {
  CoinHeader({super.key, required this.viewModel});

  final AppLocalizations intl = sl<GlobalAppLocalizations>().current;
  final CoinDetailsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.transparentWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: NetworkImageWidget(
                  url: viewModel.coin.image,
                  fit: BoxFit.cover,
                  size: const Size(50, 50),
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.large(
                      viewModel.coin.name,
                      style: MyTextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppText.medium(
                      viewModel.coin.symbol?.toUpperCase() ?? '',
                      style: MyTextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: AppText.medium(
                          viewModel.isFavorite
                              ? intl.remove_from_favorites
                              : intl.add_to_favorites,
                          style: MyTextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textGray,
                          ),
                        ),
                        content: AppText.mediumSmall(
                          viewModel.isFavorite
                              ? intl.remove_from_favorites_confirmation(
                                viewModel.coin.name,
                              )
                              : intl.add_to_favorites_confirmation(
                                viewModel.coin.name,
                              ),
                          style: MyTextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textGray,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: AppText.small(
                              intl.cancel_label,
                              style: MyTextStyle(color: Colors.black),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              viewModel.toggleFavorite();
                              Navigator.of(context).pop();
                            },
                            child: AppText.small(
                              intl.yes_label,
                              style: MyTextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.transparentWhite,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    viewModel.isFavorite ? Icons.star : Icons.star_border,
                    color:
                        viewModel.isFavorite
                            ? AppColors.primaryTransparentOrange
                            : AppColors.disabledGray,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.large(
                    CurrencyFormatter.formatCurrencyForCurrentLocale(
                      viewModel.coin.currentPrice,
                      countryCode: intl.country_code,
                    ),
                    style: MyTextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        viewModel.isPositiveChange
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color:
                            viewModel.isPositiveChange
                                ? AppColors.positiveGreen
                                : AppColors.negativeRed,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      AppText.medium(
                        '${viewModel.coin.priceChangePercertage24h.toStringAsFixed(2)}%',
                        style: MyTextStyle(
                          color:
                              viewModel.isPositiveChange
                                  ? AppColors.positiveGreen
                                  : AppColors.negativeRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText.small(
                  '#${viewModel.coin.marketCapRank}',
                  style: MyTextStyle(
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
