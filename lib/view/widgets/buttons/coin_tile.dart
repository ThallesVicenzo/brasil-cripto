import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/view/widgets/colors/app_colors.dart';
import 'package:brasil_cripto/view/widgets/images/network_image_widget.dart';
import 'package:brasil_cripto/view/widgets/text/app_text.dart';
import 'package:brasil_cripto/view_model/utils/formatters/currency_formatter.dart';
import 'package:flutter/material.dart';

class CoinTile extends StatelessWidget {
  CoinTile({
    super.key,
    required this.coin,
    required this.isPositive,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  final CoinModel coin;
  final bool isPositive;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  final AppLocalizations intl = sl<GlobalAppLocalizations>().current;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.transparentWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: AppText.small(
                  '${coin.marketCapRank}',
                  style: MyTextStyle(
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: NetworkImageWidget(
                url: coin.image,
                fit: BoxFit.cover,
                size: const Size(40, 40),
                alignment: Alignment.center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.mediumSmall(
                    coin.name,
                    style: MyTextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.small(
                        coin.symbol?.toUpperCase() ?? '',
                        style: MyTextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AppText.extraSmall(
                        'Cap: ${CurrencyFormatter.formatCurrencyCompact(coin.marketCap, countryCode: intl.localeName)}',
                        style: MyTextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText.mediumSmall(
                  CurrencyFormatter.formatCurrencyForCurrentLocale(
                    coin.currentPrice,
                    countryCode: intl.country_code,
                  ),
                  style: MyTextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        color:
                            isPositive
                                ? AppColors.positiveGreen
                                : AppColors.negativeRed,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      AppText.small(
                        '${coin.priceChangePercertage24h.abs().toStringAsFixed(2)}%',
                        style: MyTextStyle(
                          color:
                              isPositive
                                  ? AppColors.positiveGreen
                                  : AppColors.negativeRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onFavoriteTap,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.transparentWhite,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color:
                      isFavorite
                          ? AppColors.primaryTransparentOrange
                          : AppColors.disabledGray,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
