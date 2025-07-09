import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigator {
  const AppNavigator(this.context);
  final BuildContext context;

  void popUntil(String routeName, {dynamic result}) {
    final router = GoRouterState.of(context);
    while (router.uri.toString() != '/$routeName' && context.canPop()) {
      context.pop(result);
    }

    /// Fallback to pushNamed if routeName is not found
    if (router.uri.toString() != '/$routeName') {
      pushNamed(routeName);
    }
  }

  Future<T?> popAllAndPushNamed<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const <String, String>{},
  }) async {
    while (context.canPop()) {
      context.pop();
    }

    T? result = await context.pushNamed(
      routeName,
      pathParameters: pathParameters,
    );

    return result;
  }

  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const <String, String>{},
    Object? extra,
  }) async {
    T? result = await context.pushNamed(
      routeName,
      pathParameters: pathParameters,
      extra: extra,
    );

    return result;
  }

  void pushReplaceNamed(
    String routeName, {
    Map<String, String> pathParameters = const <String, String>{},
    Object? extra,
  }) {
    context.pushReplacementNamed(
      routeName,
      pathParameters: pathParameters,
      extra: extra,
    );
  }

  void goNamed(
    String routeName, {
    Map<String, String> pathParameters = const <String, String>{},
    Object? extra,
  }) {
    context.goNamed(routeName, pathParameters: pathParameters, extra: extra);
  }

  void replaceNamed(
    String routeName, {
    Map<String, String> pathParameters = const <String, String>{},
    Object? extra,
  }) {
    context.replaceNamed(
      routeName,
      pathParameters: pathParameters,
      extra: extra,
    );
  }

  void pop<T extends Object?>([T? result]) {
    if (context.canPop()) {
      context.pop(result);
    }
  }

  String location() {
    return GoRouterState.of(context).uri.toString();
  }
}
