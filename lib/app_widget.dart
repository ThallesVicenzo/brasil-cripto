import 'package:brasil_cripto/view/utils/routes/manager/app_main_routes_manager.dart';
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
      theme: ThemeData(scaffoldBackgroundColor: Colors.black87),
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).removeCurrentSnackBar(reason: SnackBarClosedReason.swipe);
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: UiOverlayColor(child: child!),
        );
      },
    );
  }
}
