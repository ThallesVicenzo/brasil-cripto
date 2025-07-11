import 'package:brasil_cripto/model/models/coin_model.dart';
import 'package:brasil_cripto/view/pages/coin_details/coin_details_page.dart';
import 'package:brasil_cripto/view/pages/home_page.dart';
import 'package:brasil_cripto/view/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

final router = GoRouter(
  navigatorKey: NavigationService.navigatorKey,
  initialLocation: '/',
  observers: [],
  routes: [
    GoRoute(
      path: '/',
      name: '/',
      pageBuilder:
          (context, state) =>
              MaterialPage(child: const WelcomePage(), name: state.name),
    ),
    GoRoute(
      path: '/home',
      name: '/home',
      pageBuilder:
          (context, state) =>
              MaterialPage(child: const HomePage(), name: state.name),
    ),
    GoRoute(
      path: '/coin-details',
      name: '/coin-details',
      pageBuilder: (context, state) {
        final coin = state.extra as CoinModel;
        return MaterialPage(
          child: CoinDetailsPage(coin: coin),
          name: state.name,
        );
      },
    ),
  ],
);
