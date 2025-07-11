import 'dart:async';

import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/view/utils/routes/app_navigator/app_navigator.dart';
import 'package:brasil_cripto/view/utils/routes/main_routes.dart';
import 'package:brasil_cripto/view/utils/widgets/buttons/default_button.dart';
import 'package:brasil_cripto/view/utils/widgets/colors/ui_overlay_color.dart';
import 'package:brasil_cripto/view/utils/widgets/images/asset_image_widget.dart';
import 'package:brasil_cripto/view/utils/widgets/spacing/default_padding.dart';
import 'package:brasil_cripto/view_model/utils/enums/app_images.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  double titleOpacity = 0;
  double subtitleOpacity = 0;

  final localizations = sl<GlobalAppLocalizations>().current;

  @override
  void initState() {
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        titleOpacity = 1;
      });
    });
    Timer(const Duration(seconds: 1), () {
      setState(() {
        subtitleOpacity = 1;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.sizeOf(context);

    return UiOverlayColor(
      overlayColor: Colors.transparent,
      child: Scaffold(
        body: DefaultPadding(
          includeHorizontal: false,
          child: Column(
            children: [
              AnimatedOpacity(
                opacity: titleOpacity,
                duration: Duration(milliseconds: 500),
                child: AssetImageWidget(
                  image: AppImage.logo,
                  fit: BoxFit.contain,
                  size: Size(deviceSize.width, 500),
                ),
              ),
              const Spacer(),
              AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: subtitleOpacity,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: deviceSize.width * 0.05,
                  ),
                  child: DefaultButton(
                    label: localizations.start_label,
                    onPressed: () {
                      AppNavigator(
                        context,
                      ).pushReplaceNamed(MainRoutes.home.route);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
