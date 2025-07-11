import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/view/pages/coin_details/widgets/chart_section.dart';
import 'package:brasil_cripto/view/pages/coin_details/widgets/coin_header.dart';
import 'package:brasil_cripto/view/pages/coin_details/widgets/stats_section.dart';
import 'package:brasil_cripto/view/utils/widgets/app_bar/default_app_bar.dart';
import 'package:brasil_cripto/view/utils/widgets/spacing/default_padding.dart';
import 'package:brasil_cripto/view_model/coin_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CoinDetailsPage extends StatefulWidget {
  const CoinDetailsPage({super.key, required this.coin});

  final CoinModel coin;

  @override
  State<CoinDetailsPage> createState() => _CoinDetailsPageState();
}

class _CoinDetailsPageState extends State<CoinDetailsPage> {
  final intl = sl<GlobalAppLocalizations>().current;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CoinDetailsViewModel(widget.coin, sl()),
      child: Scaffold(
        appBar: DefaultAppBar(title: intl.details, hasLeading: true),
        body: Consumer<CoinDetailsViewModel>(
          builder: (context, viewModel, child) {
            return DefaultPadding.noTop(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CoinHeader(viewModel: viewModel),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ChartSection(viewModel: viewModel),
                    ),
                    StatsSection(viewModel: viewModel),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
