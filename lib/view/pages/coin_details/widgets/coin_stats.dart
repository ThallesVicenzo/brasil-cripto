import 'package:brasil_cripto/view/utils/widgets/colors/app_colors.dart';
import 'package:brasil_cripto/view/utils/widgets/text/app_text.dart';
import 'package:flutter/material.dart';

class CoinStats extends StatelessWidget {
  const CoinStats({
    super.key,
    required this.label,
    required this.value,
    this.textColor,
  });

  final String label;
  final String value;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.mediumSmall(
            label,
            style: MyTextStyle(
              color: AppColors.textGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppText.mediumSmall(
            value,
            style: MyTextStyle(
              color: textColor ?? Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
