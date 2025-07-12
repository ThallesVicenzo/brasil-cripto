import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/view/pages/coin_details/widgets/coin_stats.dart';
import 'package:brasil_cripto/view/widgets/colors/app_colors.dart';
import 'package:brasil_cripto/view/widgets/text/app_text.dart';
import 'package:brasil_cripto/view_model/coin_details_view_model.dart';
import 'package:brasil_cripto/view_model/utils/formatters/currency_formatter.dart';
import 'package:flutter/material.dart';

class StatsSection extends StatelessWidget {
  StatsSection({super.key, required this.viewModel});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            intl.statistics,
            style: MyTextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CoinStats(
            label: intl.market_cap,
            value: CurrencyFormatter.formatCurrencyCompact(
              viewModel.coin.marketCap,
              countryCode: intl.localeName,
            ),
          ),
          CoinStats(
            label: intl.market_ranking,
            value: '#${viewModel.coin.marketCapRank}',
          ),
          CoinStats(
            label: intl.change_24h,
            value:
                '${viewModel.coin.priceChangePercertage24h.toStringAsFixed(2)}%',
            textColor:
                viewModel.isPositiveChange
                    ? AppColors.positiveGreen
                    : AppColors.negativeRed,
          ),
          CoinStats(
            label: intl.price_change_24h,
            value: CurrencyFormatter.formatCurrencyForCurrentLocale(
              viewModel.priceChangeAmount,
              countryCode: intl.country_code,
            ),
            textColor:
                viewModel.isPositiveChange
                    ? AppColors.positiveGreen
                    : AppColors.negativeRed,
          ),
        ],
      ),
    );
  }
}
