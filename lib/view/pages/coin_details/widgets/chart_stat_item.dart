import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/view/utils/widgets/colors/app_colors.dart';
import 'package:brasil_cripto/view/utils/widgets/text/app_text.dart';
import 'package:flutter/material.dart';

class ChartStatItem extends StatelessWidget {
  ChartStatItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final intl = sl<GlobalAppLocalizations>().current;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label == intl.chart_min || label == intl.chart_max)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                margin: const EdgeInsets.only(right: 4),
              ),
            Flexible(
              child: AppText.small(
                label,
                style: MyTextStyle(
                  color: AppColors.textGray,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Flexible(
          child: AppText(
            value,
            style: MyTextStyle(color: color, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            fontSize: value.length > 10 ? FontSize.small : FontSize.mediumSmall,
          ),
        ),
      ],
    );
  }
}
