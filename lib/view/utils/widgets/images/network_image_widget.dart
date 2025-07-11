import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NetworkImageWidget extends StatelessWidget {
  final String url;
  final Size size;
  final BoxFit fit;
  final Alignment alignment;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const NetworkImageWidget({
    super.key,
    required this.url,
    this.size = const Size(24, 24),
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: size.width,
      height: size.height,
      fit: fit,
      alignment: alignment,
      errorBuilder:
          errorBuilder ??
          (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Icon(
                Icons.close,
                color: Colors.grey[400],
                size: size.height,
              ),
            );
          },
    );
  }
}
