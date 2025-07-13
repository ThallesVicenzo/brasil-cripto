import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/view/pages/coin_details/widgets/chart_stat_item.dart';
import 'package:brasil_cripto/view/widgets/colors/app_colors.dart';
import 'package:brasil_cripto/view_model/coin_details_view_model.dart';
import 'package:brasil_cripto/view_model/utils/formatters/currency_formatter.dart';
import 'package:flutter/material.dart';

class ChartStats extends StatelessWidget {
  ChartStats({super.key, required this.viewModel});

  final AppLocalizations intl = sl<GlobalAppLocalizations>().current;
  final CoinDetailsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: ChartStatItem(
              label: intl.chart_min,
              value: CurrencyFormatter.formatCurrencyForCurrentLocale(
                viewModel.chartMinPrice,
                countryCode: intl.country_code,
              ),
              color: AppColors.negativeRed,
            ),
          ),
          Expanded(
            child: ChartStatItem(
              label: intl.chart_max,
              value: CurrencyFormatter.formatCurrencyForCurrentLocale(
                viewModel.chartMaxPrice,
                countryCode: intl.country_code,
              ),
              color: AppColors.positiveGreen,
            ),
          ),
          Expanded(
            child: ChartStatItem(
              label: intl.chart_variation,
              value:
                  '${viewModel.chartPriceChangePercent >= 0 ? '+' : ''}${viewModel.chartPriceChangePercent.toStringAsFixed(2)}%',
              color:
                  viewModel.isChartPositive
                      ? AppColors.positiveGreen
                      : AppColors.negativeRed,
            ),
          ),
        ],
      ),
    );
  }
}
