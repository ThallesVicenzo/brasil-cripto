import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/view/utils/routes/manager/app_main_routes_manager.dart';
import 'package:brasil_cripto/view/utils/widgets/animations/falling_coins_background.dart';
import 'package:brasil_cripto/view/utils/widgets/colors/ui_overlay_color.dart';
import 'package:flutter/material.dart';

class BrasilCripto extends StatelessWidget {
  const BrasilCripto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Brasil Cripto',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(scaffoldBackgroundColor: Colors.transparent),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        sl<GlobalAppLocalizations>().setAppLocalizations(
          AppLocalizations.of(context),
        );

        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).removeCurrentSnackBar(reason: SnackBarClosedReason.swipe);
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: FallingCoinsBackground(
            numberOfCoins: 20,
            child: UiOverlayColor(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: child!,
              ),
            ),
          ),
        );
      },
    );
  }
}
