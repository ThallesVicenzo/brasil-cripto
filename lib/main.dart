import 'package:brasil_cripto/app_injector.dart' as injector;
import 'package:brasil_cripto/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  await injector.init();

  runApp(const BrasilCripto());
}
