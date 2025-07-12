import 'package:flutter/material.dart';

class DefaultPadding extends StatelessWidget {
  const DefaultPadding({
    super.key,
    required this.child,
    this.includeTop = true,
    this.includeHorizontal = true,
    this.customTop,
  });

  const DefaultPadding.noTop({super.key, required this.child})
    : includeTop = false,
      includeHorizontal = true,
      customTop = null;

  const DefaultPadding.customTop({
    super.key,
    required this.child,
    required double top,
  }) : includeTop = true,
       includeHorizontal = true,
       customTop = top;

  final Widget child;
  final bool includeTop;
  final bool includeHorizontal;
  final double? customTop;

  static const double _defaultTop = 72.0;
  static const double _defaultHorizontal = 16.0;
  static const double _defaultBottom = 40.0;

  @override
  Widget build(BuildContext context) {
    final double topPadding = includeTop ? (customTop ?? _defaultTop) : 0.0;
    final double horizontalPadding =
        includeHorizontal ? _defaultHorizontal : 0.0;

    return Padding(
      padding: EdgeInsets.only(
        top: topPadding,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: _defaultBottom,
      ),
      child: child,
    );
  }

  static EdgeInsets get defaultPadding => const EdgeInsets.only(
    top: _defaultTop,
    left: _defaultHorizontal,
    right: _defaultHorizontal,
    bottom: _defaultBottom,
  );

  static EdgeInsets get noPadding => const EdgeInsets.only(
    left: _defaultHorizontal,
    right: _defaultHorizontal,
    bottom: _defaultBottom,
  );

  static EdgeInsets customTopPadding(double top) => EdgeInsets.only(
    top: top,
    left: _defaultHorizontal,
    right: _defaultHorizontal,
    bottom: _defaultBottom,
  );
}
