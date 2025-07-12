import 'package:brasil_cripto/view/utils/widgets/colors/app_colors.dart';
import 'package:brasil_cripto/view/utils/widgets/text/app_text.dart';
import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 56,
    this.width = double.infinity,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryTransparentOrange,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: AppText.mediumSmall(
            label,
            style: MyTextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
