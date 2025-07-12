import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/view/utils/widgets/colors/app_colors.dart';
import 'package:brasil_cripto/view/utils/widgets/text/app_text.dart';
import 'package:brasil_cripto/view_model/home_view_model.dart';
import 'package:flutter/material.dart';

class ErrorBox extends StatelessWidget {
  final intl = sl<GlobalAppLocalizations>().current;
  final HomeViewModel viewModel = sl<HomeViewModel>();

  ErrorBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          SizedBox(height: 16),
          AppText.medium(
            viewModel.errorMessage!,
            style: MyTextStyle(
              color: AppColors.negativeRed,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              viewModel.clearError();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: AppText(intl.ok_label),
          ),
        ],
      ),
    );
  }
}
