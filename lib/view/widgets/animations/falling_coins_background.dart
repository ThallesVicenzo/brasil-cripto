import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/model/models/coin_animation_model.dart';
import 'package:brasil_cripto/view_model/falling_coins_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FallingCoinsBackground extends StatefulWidget {
  final Widget child;
  final int numberOfCoins;
  final Duration animationDuration;

  const FallingCoinsBackground({
    super.key,
    required this.child,
    this.numberOfCoins = 15,
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<FallingCoinsBackground> createState() => _FallingCoinsBackgroundState();
}

class _FallingCoinsBackgroundState extends State<FallingCoinsBackground>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final FallingCoinsViewModel _viewModel = sl<FallingCoinsViewModel>();
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    final currentKeyboardVisible = mediaQuery.viewInsets.bottom > 0;

    if (_isKeyboardVisible != currentKeyboardVisible) {
      _isKeyboardVisible = currentKeyboardVisible;
      _viewModel.setKeyboardVisibility(_isKeyboardVisible);
    }

    if (!_viewModel.isInitialized || !_isKeyboardVisible) {
      _viewModel.updateScreenDimensions(
        mediaQuery.size.width,
        mediaQuery.size.height,
      );
    }

    if (!_viewModel.isInitialized) {
      _viewModel.initializeAnimations(
        vsync: this,
        numberOfCoins: widget.numberOfCoins,
        animationDuration: widget.animationDuration,
      );
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final mediaQuery = MediaQuery.of(context);
        final keyboardVisible = mediaQuery.viewInsets.bottom > 0;

        if (_isKeyboardVisible != keyboardVisible) {
          _isKeyboardVisible = keyboardVisible;
          _viewModel.setKeyboardVisibility(_isKeyboardVisible);
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<FallingCoinsViewModel>(
        builder: (context, viewModel, _) {
          if (!viewModel.isInitialized) {
            return ColoredBox(
              color: Colors.black,
              child: SizedBox.expand(child: widget.child),
            );
          }

          return Stack(
            children: [
              const ColoredBox(color: Colors.black, child: SizedBox.expand()),
              ...List.generate(viewModel.activeCoinsCount, (index) {
                return AnimatedBuilder(
                  animation: viewModel.animations[index],
                  builder: (context, child) {
                    final position = viewModel.calculateCoinPosition(index);

                    if (!position.isVisible) {
                      return const SizedBox.shrink();
                    }

                    return Positioned(
                      left: position.x,
                      top: position.y,
                      child: Transform.rotate(
                        angle: position.rotation,
                        child: child!,
                      ),
                    );
                  },
                  child: RepaintBoundary(
                    child: _CoinWidget(coin: viewModel.coins[index]),
                  ),
                );
              }),
              widget.child,
            ],
          );
        },
      ),
    );
  }
}

class _CoinWidget extends StatelessWidget {
  final CoinAnimationModel coin;

  const _CoinWidget({required this.coin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: coin.size,
      height: coin.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: coin.coinType.colors,
          center: const Alignment(-0.3, -0.3),
          stops: const [0.0, 0.7, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          coin.coinType.symbol,
          style: TextStyle(
            color: Colors.white,
            fontSize: coin.size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
