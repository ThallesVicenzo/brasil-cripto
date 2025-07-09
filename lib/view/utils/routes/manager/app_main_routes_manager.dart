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
    // GoRoute(
    //   path: '/home',
    //   name: '/home',
    //   pageBuilder:
    //       (context, state) =>
    //           MaterialPage(child: const HomePage(), name: state.name),
    // ),
  ],
);
