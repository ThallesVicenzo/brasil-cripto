import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/view/widgets/colors/app_colors.dart';
import 'package:brasil_cripto/view/widgets/text/app_text.dart';
import 'package:brasil_cripto/view_model/home_view_model.dart';
import 'package:flutter/material.dart';

class FavoritationDialog extends StatelessWidget {
  FavoritationDialog({
    super.key,
    required this.isFavorite,
    required this.coin,
    required this.viewModel,
    this.onFavorited,
  });

  final bool isFavorite;
  final CoinModel coin;
  final HomeViewModel? viewModel;
  final VoidCallback? onFavorited;

  final intl = sl<GlobalAppLocalizations>().current;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppText.medium(
        isFavorite ? intl.remove_from_favorites : intl.add_to_favorites,
        style: MyTextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textGray,
        ),
      ),
      content: AppText.mediumSmall(
        isFavorite
            ? intl.remove_from_favorites_confirmation(coin.name)
            : intl.add_to_favorites_confirmation(coin.name),
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
          onPressed: onFavorited,
          child: AppText.small(
            intl.yes_label,
            style: MyTextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
